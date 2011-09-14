/*
 * CP2JSCoder.j
 *
 * Created by Jerome Denanot on April, 04, 2009.
 * Copyright 2009 Jerome Denanot.
 *
 * CP2JavaWS Objective-J classes and Java servlet are provided under LGPL License from Free software foundation (a copy is included in this  
 * distribution).
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 */
 
@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>
@import <Foundation/CPDictionary.j>
@import <Foundation/CPCoder.j>

/*
* Keyed archivers in Cocoa/Cappuccino are intended to archive all objects at root level (no nested objects),
* and add references for duplicates (references to other root level objects). Moreover the encodeObject
* method of CPCoder's CPCoding protocol (visitor pattern) does not return anything. 
* The JSON format requires nested objects serialization (and so encodeObject would have to return a new JSObject,
* for each node/level).
* The following code then uses instead some of a cursor to a _currentJSObject, with new context and restore.
* The _rootJSObject maintains the root level of the contexts (JSObjects) graph.
*
* As CPArray and CPdictionary implementations of CPCoding passe the "CP.objects" key, a dummy root JS object has been
* used for these nodes, and the corresponding computed JS Object (value for the "CP.objects" key of the dummy
* root js object) is attached to the previous _currentJSObject.
*
* As CPString do not implement CPCoding an encodeString:forKey method has been defined in CP2JSCoder,
* to avoid creation of a nested JSObject (such method does not exist in original NSKeyedArchiver).
* CPCoder superclass also do not implements base encodeInt, encodeDouble, etc. (are defined in CPKeyedArchiver).
* However as there is no check for selectors at compile time in ObjJ/ObjC, custom objects's CPCoding implementations can call
* encodeString/decodeString on the passed coder (CPCoder in method signature, but CP2JSCoder at runtime).
*
* That coder provides backward compatibility with previous versions of CP2JavaWS that were based on the CPJSONAware
* protocol : if no CPCoding implementation is found, it uses instead the old toJSObject/objectWithJSObject methods
* from CPJSONAware categories.
* Furthermore it does the switch at each node level ! That is for custom objects we can etiher implement CPCoding
* protocol's methods (if the serialization requires particular work, for example to exclude some attributes
* or choose arbitrary JSON keys - different from ivar names), or benefit from the automatic encoding
* of objects provided by the CPJSONAware categories (then custom objects have to import CPObject_CPJSONAware.j,
* and JSON keyds will match exactly ivar names).
*
* CPNumber implements CPCoding : it will be ok if CPNumber fields are encoded by calling encodeNumber:forKey from objects
* implementing CPCoding. However if we use automatic encoding (through CPJSONAware's toJSObject method) on a root object
* (that then doesn't implement CPCoding) that has a CPNumber field, as toJSObject checks for each field if it implements
* encodeWithCoder, it would call encodeRootObjectToJS, and then create a nested JS object (we don't want this for a number in the
* json string). So in toJSObject we test if the field is a CPNumber after testing if it implements encodeWithCoder, and we call
* toJSObject instead of CP2JSCoder's encodeRootObjectToJS if it is.
*
*/

var REF_OBJECT_PREFIX = "$ref:";

var _IS_SAFARI_OR_FIREFOX = false;
if (typeof window != "undfined" && typeof window.navigator != "undefined") {
	var USER_AGENT = window.navigator.userAgent;
	if (USER_AGENT.indexOf("AppleWebKit/")!= -1 || USER_AGENT.indexOf("Gecko")!= -1) {
		_IS_SAFARI_OR_FIREFOX = true;
	}
}

/*function getDST() {
	var now_local = new Date();
	var jan_local = new Date(now_local.getFullYear(), 0, 1, 0, 0, 0, 0);
	var jun_local = new Date(now_local.getFullYear(), 5, 1, 0, 0, 0, 0);
	var now_utc = new Date(now_local.getUTCFullYear(), now_local.getUTCMonth(), now_local.getUTCDate(), now_local.getUTCHours(), now_local.getUTCMinutes(), now_local.getUTCSeconds());
	var jan_utc = new Date(jan_local.getUTCFullYear(), jan_local.getUTCMonth(), jan_local.getUTCDate(), jan_local.getUTCHours(), jan_local.getUTCMinutes(),		jan_local.getUTCSeconds());
	var jun_utc = new Date(jun_local.getUTCFullYear(), jun_local.getUTCMonth(), jun_local.getUTCDate(), jun_local.getUTCHours(), jun_local.getUTCMinutes(), jun_local.getUTCSeconds());
	var now_diff = parseInt((now_local - now_utc) / (1000 * 3600));
	var jan_diff = parseInt((jan_local - jan_utc) / (1000 * 3600));
	var jun_diff = parseInt((jun_local - jun_utc) / (1000 * 3600));
	if(jan_diff != jun_diff && now_diff == Math.max(jan_diff, jun_diff)) {
		return 60; // one hour in mn
	}
	return 0;
}

var _DST = getDST();*/


@implementation CP2JSCoder : CPCoder {

	JSObject _currentJSObject;
	CPDictionary hashToPath; // for each object that has been converted, maps its hash to the path where it was found
	// (in order to replace later references to same object with $ref:path in the returned js). We only manage custom objects, 
	// and not CPDate (don't have __adress, so error with hash method). Or we can check for the __adress field (then we could
	// also manage arrays and dictionaries - keep references for them to avoid duplicates). We won't be able to manage dates however.
	CPString _currentPath;
}

- (id)initForWriting {

   self = [super init];
   if (self) {
   		hashToPath = [CPDictionary dictionary];
   		_currentPath = "";
   	}
   	return self;
}

+(JSObject)encodeRootObjectToJS:(id)aRootObject {

  var archiver = [[self alloc] initForWriting];
  return [archiver encodeObject:aRootObject];
}

- (void)encodeDate:(CPDate)aDate forKey:(CPString)aKey {

	if(aDate!=null) {
   		_currentJSObject[aKey] = [self jsObjectForDate:aDate];
   	}
}

- (void)encodeBool:(BOOL)aBOOL forKey:(CPString)aKey {

	if(aBOOL!=null) {
		_currentJSObject[aKey] = aBOOL;
	}
}

- (void)encodeDouble:(double)aDouble forKey:(CPString)aKey {

	if(aDouble!=null) {
		_currentJSObject[aKey] = aDouble;
	}
}

- (void)encodeFloat:(float)aFloat forKey:(CPString)aKey {

	if(aFloat!=null) {
		_currentJSObject[aKey] = aFloat;
	}
}

- (void)encodeInt:(int)anInt forKey:(CPString)aKey {

   if(anInt!=null) {
   		_currentJSObject[aKey] = anInt;
   }
}

- (void)encodeNumber:(CPNumber)aNumber forKey:(CPString)aKey {

	if(aNumber!=null) {
   		_currentJSObject[aKey] = aNumber;
   	}
}

- (void)encodeString:(CPString)aString forKey:(CPString)aKey {

	if(aString!=null) {
   		_currentJSObject[aKey] = aString;
   	}
}

-(JSObject)jsObjectForDate:(CPDate)aDate {

	var aJSObject = {};
	aJSObject["__objjClassName"] = @"CPDate";
    aJSObject["__timestamp"] = aDate.getTime();
    if(_IS_SAFARI_OR_FIREFOX) { // timeZone value is reversed in Safari and Firefox
    	aJSObject["__timezoneOffset"] = -aDate.getTimezoneOffset();
    	//aJSObject["__timezoneOffset"] = -aDate.getTimezoneOffset() - _DST;
    } else {
    	aJSObject["__timezoneOffset"] = aDate.getTimezoneOffset();
    	//aJSObject["__timezoneOffset"] = aDate.getTimezoneOffset() - _DST;
    }
	return aJSObject;
}

- (void)encodeObject:(id)anObject forKey:(CPString)aKey
{
	if(anObject!=null) {
		
    	var previousCurrentJSObject = _currentJSObject;
    	var previousPath = _currentPath;
    	if(_currentPath.length==0) {
    		_currentPath = aKey;
    	} else {
    		_currentPath = _currentPath + "." + aKey;
    	}
    	previousCurrentJSObject[aKey] = [self encodeObject:anObject];
    	_currentJSObject = previousCurrentJSObject; // required if enCodeXX:forKey called for other attributes of the same level
    	_currentPath = previousPath;
    }
}

// used with the array's attribute key from encodeWithCoder implementation in custom objects.
// CP.objects key only passed when called from CPArray's encodeWithCoder (called from encodeObject for root or nested arrays in array or dictionary)
- (void)_encodeArrayOfObjects:(CPArray)objects forKey:(CPString)aKey {

	var nestedJSArray = [];
	var previousCurrentJSObject = _currentJSObject;
    var previousPath = _currentPath;
    _currentJSObject[aKey] = nestedJSArray;
    var i=0, count = objects.length;
    for(;i<count;i++) {
    	if(aKey!="CP.objects" && _currentPath.charAt(_currentPath.length-1)!=']' && _currentPath.charAt(_currentPath.length-1)!=')') {
     		_currentPath = previousPath + "." + aKey + "[" + i + "]";
		} else {
     		_currentPath = previousPath + "[" + i + "]"; // nested array in array or dictionary ("CP.objects" passed as aKey, ignored)
		}
		var element = [objects objectAtIndex:i];
		nestedJSArray[i] = [self encodeObject:element];
	}
	_currentJSObject = previousCurrentJSObject;
	_currentPath = previousPath;
}

- (void)_encodeDictionaryOfObjects:(CPDictionary)aDictionary forKey:(CPString)aKey {

	 var nestedJSObject = {};
     var previousCurrentJSObject = _currentJSObject;
     var previousPath = _currentPath;
     _currentJSObject[aKey] = nestedJSObject;
	 var key,
         keys = [aDictionary keyEnumerator];
     
     while ((key = [keys nextObject])!==null) {
     	if(aKey!="CP.objects" && _currentPath.charAt(_currentPath.length-1)!=']' && _currentPath.charAt(_currentPath.length-1)!=')') {
     	  	_currentPath = previousPath + "." + aKey + "(" + key + ")";
     	} else {
     	  	_currentPath = previousPath + "(" + key + ")"; // nested dictionary in array or dictionary ("CP.objects" passed as aKey, ignored)
     	}
     	var element = [aDictionary objectForKey:key];
     	nestedJSObject[key] = [self encodeObject:element];
     }
     _currentJSObject = previousCurrentJSObject;
     _currentPath = previousPath;
     nestedJSObject["__objjClassName"] = "CPDictionary"; // not need for CPArray (_encodeArrayOfObjects attachs an array)
}

- (JSObject)encodeObject:(id)anObject {

	if(!anObject.isa || anObject.isa.name=="CPString" || anObject.isa.name=="CPNumber") {
		return anObject;	
	}
	
	if(anObject.isa.name=='CPDate') {
		return [self jsObjectForDate:anObject];
    }
    // if we want also to avoid duplicate for arrays we have to check for the __adress field (not found in CPDate so error with hash method)
    // we won't be able to manage duplicates for dates (so always consider the object isn't a duplicate - duplicate set to false - if no __adress field)          
    var duplicate = false;
    if(anObject["__address"]) {
       	if([hashToPath valueForKey:[anObject hash]]!=null) {
       		duplicate = true;
       	} else {
       		[hashToPath setValue:_currentPath forKey:[anObject hash]];
       	}
    }
    if(duplicate) {
       	return REF_OBJECT_PREFIX + [hashToPath valueForKey:[anObject hash]];
          
    } else {
          
       	if(isArray(anObject) || isDictionary(anObject)) {
           	_currentJSObject = {}; // dummy root JS for collection
           	[anObject encodeWithCoder:self];
           	return _currentJSObject["CP.objects"];
      	} else {
       		_currentJSObject = {};
       		_currentJSObject["__objjClassName"] = [[anObject class] className];
       		if([anObject respondsToSelector:@selector(encodeWithCoder:)]) {
         		
      			[anObject encodeWithCoder:self];

    		} else { // automatic encoding
    			
    			for(var _propertyName in anObject) { // pb if var is called name and the object has an attribute called "name", so we use _propertyName
					if(anObject.hasOwnProperty(_propertyName) && _propertyName != "isa" && _propertyName != "__address" && anObject[_propertyName]!=null) { // [Fix by Dimitris Tsitses 06/2010] : anObject[_propertyName] can return false if value is 0 (integer) or false (boolean), then we have to compare with null
	   				// we could use ivars field on anObject's CPClass object
						[self encodeObject:anObject[_propertyName] forKey:_propertyName];
	   				}
				}
   			}
   			return _currentJSObject;
   		}    		
	}
}

@end


function isArray(obj) {

	return obj.constructor == Array;
}

function isDictionary(obj) {

	return (obj.isa!=null)&&((obj.isa.name == "CPDictionary") || (obj.isa.name == "CPMutableDictionary"));
}

