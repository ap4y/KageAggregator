
/*
 * CPPropertyUtils.j
 *
 * Created by Jerome Denanot on April, 06, 2009.
 * Copyright 2009 Jerome Denanot.
 *
 * CP2JavaWS Objective-J classes and Java servlet are provided under LGPL License from Free software foundation (a copy is included in this  
 * distribution).
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 */
 
@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>

@implementation CPPropertyUtils : CPObject {

}

+(id) getNestedPropertyFromRoot:(id)rootObject forKey:(CPString)aKey {

    var indexStartRange = aKey.indexOf('[');
    var keyStartRange = aKey.indexOf('(');
    var k = Math.min(indexStartRange, keyStartRange);
    if(indexStartRange<0 && keyStartRange<0) {
       return [rootObject valueForKeyPath:aKey]
    }
    if((keyStartRange<0)||(indexStartRange>=0 && k==indexStartRange)) {
	   
       var indexEndRange = aKey.indexOf(']');
       var indexRange = CPMakeRange(indexStartRange+1, indexEndRange-indexStartRange-1);
       var elementIndex = [aKey substringWithRange:indexRange];
       var theArray;
       if(indexStartRange==0) {
       		theArray = rootObject;
       } else {
       		var arrayPath = [aKey substringToIndex:indexStartRange];
       		theArray = [rootObject valueForKeyPath:arrayPath];
       } 
       var arrayElement = [theArray objectAtIndex:elementIndex];
       if(indexEndRange+1 < aKey.length) {
       		var nextPath;
       		if(aKey.charAt(indexEndRange+1)=='.') {
       			nextPath = [aKey substringFromIndex:indexEndRange+2];
       		} else {
       			nextPath = [aKey substringFromIndex:indexEndRange+1];
       		}
       		return [self getNestedPropertyFromRoot:arrayElement forKey:nextPath];
       	} else {
       		return arrayElement;
       	}

	} else {
	
	   var keyEndRange = aKey.indexOf(')');
       var keyRange = CPMakeRange(keyStartRange+1, keyEndRange-keyStartRange-1);
       var elementKey = [aKey substringWithRange:keyRange];
       var theDictionary;
       if(keyStartRange==0) {
       		theDictionary = rootObject;
       } else {
       		var dictionaryPath = [aKey substringToIndex:keyStartRange];
       		theDictionary = [rootObject valueForKeyPath:dictionaryPath];
       }
       var dictionaryElement = [theDictionary valueForKey:elementKey];
       if(keyEndRange+1 < aKey.length) {
       		var nextPath;
       		if(aKey.charAt(keyEndRange+1)=='.') {
       		 	nextPath = [aKey substringFromIndex:keyEndRange+2];
       		} else {
       			nextPath = [aKey substringFromIndex:keyEndRange+1];
       		}
       		return [self getNestedPropertyFromRoot:dictionaryElement forKey:nextPath];
       } else {
       		return dictionaryElement;
       }
	}  
}

+(void) setNestedPropertyForRoot:(id)rootObject forKey:(CPString)aKey value:(id)aValue {

    var indexStartPos = aKey.lastIndexOf('[');
    var keyStartPos = aKey.lastIndexOf('(');
	if(indexStartPos<0 && keyStartPos<0) {
		[rootObject setValue:aValue forKeyPath:aKey];
		
	} else if((aKey.charAt(aKey.length-1)!=']') && (aKey.charAt(aKey.length-1)!=')')) {
		var lastSegmentStart = aKey.lastIndexOf('.');
		var leftPath = [aKey substringToIndex:lastSegmentStart];
		var receivingObject =  [self getNestedPropertyFromRoot:rootObject forKey:leftPath];
		var rightPath = [aKey substringFromIndex:lastSegmentStart+1];
		[receivingObject setValue:aValue forKey:rightPath];
		
	} else {
	
		if(aKey.charAt(aKey.length-1)==']') {
			var leftPath = [aKey substringToIndex:indexStartPos];
			var receivingObject;
			if(leftPath.length==0) {
				receivingObject = rootObject;
			} else {
				receivingObject =  [self getNestedPropertyFromRoot:rootObject forKey:leftPath];
			}
			var index = aKey.substring(indexStartPos+1, aKey.length-1);
			[receivingObject replaceObjectAtIndex:index withObject:aValue]; 
			
		} else {
			var leftPath = [aKey substringToIndex:keyStartPos];
			var receivingObject;
			if(leftPath.length==0) {
				receivingObject = rootObject;
			} else {
				receivingObject =  [self getNestedPropertyFromRoot:rootObject forKey:leftPath];
			}
			var key = aKey.substring(keyStartPos+1, aKey.length-1);
			[receivingObject setValue:aValue forKey:key]; 
		}				
	}
}

// returns the class's leaf attributes paths and types
+(CPArray)propertiesForClass:(Class)aRootClass nested:(BOOL)followNested includeType:(BOOL)aType attArray:(CPArray)attributesArray path:(CPString)aPath {

	
	var ivars = aRootClass.ivars;
	var count = ivars.length;
    for(var i=0;i<count;i++) {
    	var type = ivars[i].type;
    	if(type!=nil && type!="var" && type!="CPArray" && type!="CPDictionary")
    	if(type!="CPString" && type!="CPNumber" && type!="CPDate" && type!="BOOL") {
    		var nestedClass = CPClassFromString(type);
    		if(nestedClass!=nil && nestedClass!=aRootClass) {
    			var nestedPath;
    			if(aPath==nil) {
    				nestedPath = ivars[i].name;
    			} else {
    				nestedPath = aPath+"."+ivars[i].name;
    			}
    			[self propertiesForClass:nestedClass nested:followNested includeType:aType attArray:attributesArray path:nestedPath];
    		}
    	} else {
    		var property;
    		if(aPath==nil) {
    			property = ivars[i].name;
    		} else {
    			property = aPath+"."+ivars[i].name;
    		}
    		if(aType) {
    			attributesArray.push([property, type]);
    		} else {
    			attributesArray.push(property);
    		}
    	}
    }
}

+(CPArray)propertiesForClass:(Class)aRootClass nested:(BOOL)followNested includeType:(BOOL)aType {

	var attributesArray = [CPArray alloc];
	[self propertiesForClass:aRootClass nested:followNested includeType:aType attArray:attributesArray path:nil];
	return attributesArray;
}

+(CPArray)propertiesForClassName:(CPString)aRootClassName nested:(BOOL)followNested includeType:(BOOL)aType {

	return [self propertiesForClass:CPClassFromString(aRootClassName) nested:followNested includeType:aType];
}

+(CPString)formatedNameForProperty:(CPString)aPropertyPath {

	var reg=new RegExp("\\.", "g");
	return aPropertyPath.substring(0,1).toUpperCase()+aPropertyPath.substring(1).replace(reg, " ");
}

+(CPString)ivarTypeForClass:(Class)aClass key:(CPString)aKey {

	var ivars = aClass.ivars;
	var count = ivars.length;
	for(var i=0;i<count;i++) {
		if(ivars[i].name==aKey)
			return ivars[i].type;
    }
}

// _ivarForKey returns a string (and is for instances, and isn't recursive)
+(Class)typeForRootClass:(Class)aRootClass keyPath:(CPString)aPath {

	var pathElements = aPath.split(".");
	var count = pathElements.length;
	var nestedClass = aRootClass;
	for(var i=0;i<count;i++) {
		nestedClass = CPClassFromString([self ivarTypeForClass:nestedClass key:pathElements[i]]);
	}
	return nestedClass;
}

// check that the passed path can be set on the passed object (the parent path must exist, if not we create a new
// object for the parent path - its type is computed by iterating over the class ivars -, recursively from root to parent).
+(void)checkPath:(CPString)aPath forObject:(id)aRootObject {

	var pathElements = aPath.split(".");
	var elementIndex = 0;
	var path = "";
    var count = pathElements.length -1; // we check down to the parent path 
    for(; elementIndex < count; elementIndex++) {
    	if(path.length>0) {
    		path = path+".";
    	}
    	path = path+pathElements[elementIndex];
    	if([aRootObject valueForKeyPath:path]==nil) {
    		var typeClass = [self typeForRootClass:[aRootObject class] keyPath:path];
    		var nestedObject = [typeClass alloc];
    		[aRootObject setValue:nestedObject forKeyPath:path];
    	}
    }
}


@end
