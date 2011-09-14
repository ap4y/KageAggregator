/*
 * CP2JSDecoder.j
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
@import "CPPropertyUtils.j"

/*
 * Call of _decodeArrayOfObjectsForKey in CPArray's initWithCoder has been replaced with a call to decodeObjectForKey !
 * However decodeObjectForKey method is intended for nested objects (but not for arrays)
 * --> we test in decodeObjectForKey if the key is "CP.objects", and then call _decodeArrayOfObjectsForKey.
 */
var REF_OBJECT_PREFIX = "$ref:";

var _IS_SAFARI_OR_FIREFOX = false;
if (typeof window != "undfined" && typeof window.navigator != "undefined") {
	var USER_AGENT = window.navigator.userAgent;
	if (USER_AGENT.indexOf("AppleWebKit/")!= -1 || USER_AGENT.indexOf("Gecko")!= -1) {
		_IS_SAFARI_OR_FIREFOX = true;
	}
}
 
@implementation CP2JSDecoder : CPCoder {

	JSObject _currentJSObject;
	CPDictionary pathToRef; // for a path in the root object's graph, stores the corresponding object's path (value of $ref:path).
	// Then after the root object has been decoded (one pass), we can decode the references (source object path is the dictionary  value,
	// and destination path is the dictionary key) through iterating the dictionary (we use CPPropertyUtils to get the object to affect,
	// and then to set it to the destination path).
	CPString _currentPath;
}

- (id)initForReadingWithJSObject:(JSObject)aRootJSObject {

   self = [super init];
   if (self) {
   		_currentJSObject = aRootJSObject;
   		pathToRef = [CPDictionary dictionary];
   		_currentPath = "";
   	}
   	return self;
}

+(id)decodeRootJSObject:(JSObject)aRootJSObject {

  var unarchiver = [[self alloc] initForReadingWithJSObject:aRootJSObject];
  var decodedObject = [unarchiver decodeObject];
  [unarchiver finishDecodingReferencesForRoot:decodedObject];
  return decodedObject;
}

- (void)finishDecodingReferencesForRoot:(id)decodedObject {
	
	var paths = [pathToRef keyEnumerator];
  	while (path = [paths nextObject]) {
     
   		var refValuePath = [pathToRef objectForKey:path];
   		var refValue = [CPPropertyUtils getNestedPropertyFromRoot:decodedObject forKey:refValuePath];
   		[CPPropertyUtils setNestedPropertyForRoot:decodedObject forKey:path value:refValue];
  	}
}

- (CPDate)decodeDateForKey:(CPString)aKey {
	
	if(_currentJSObject[aKey]!=null) {
	
		return [self initDateWithJSObject:_currentJSObject[aKey]];
   	}
   	return null;
}

- (BOOL)decodeBoolForKey:(CPString)aKey {
	
	 if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

- (double)decodeDoubleForKey:(CPString)aKey {

	if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

- (float)decodeFloatForKey:(CPString)aKey {

	if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

- (int)decodeIntForKey:(CPString)aKey {

   if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

- (CPNumber)decodeNumberForKey:(CPString)aKey {

	if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

- (CPString)decodeStringForKey:(CPString)aKey {

   if(_currentJSObject[aKey]!=null) {
		return _currentJSObject[aKey];
	}
	return null;
}

-(CPDate)initDateWithJSObject:(JSObject)aJSObject {

	var newDate = new Date();
	var delta;
	if(_IS_SAFARI_OR_FIREFOX) {
		delta = (-newDate.getTimezoneOffset()-aJSObject["__timezoneOffset"])*60*1000; // timeZone value is reversed in Safari and Firefox
	} else {
		delta = (newDate.getTimezoneOffset()-aJSObject["__timezoneOffset"])*60*1000;
	}
   	return new Date(aJSObject["__timestamp"]+delta); // no Date.setTimezoneOffset, or use datejs lib

}

// Call of _decodeArrayOfObjectsForKey in CPArray's initWithCoder has been replaced with a call to decodeObjectForKey!
// However decodeObjectForKey method is intended for nested objects (but not for arrays)
// --> we have to test if the key is "CP.objects", and then call _decodeArrayOfObjectsForKey.
- (id)decodeObjectForKey:(CPString)aKey
{
	if(aKey=="CP.objects" && isArray(_currentJSObject)) {
		return [self _decodeArrayOfObjectsForKey:aKey];
	}
	if(_currentJSObject[aKey]!=null) {
    	var previousCurrentJSObject = _currentJSObject;
    	var previousPath = _currentPath;
    	if(_currentPath.length==0) {
    		_currentPath = aKey;
    	} else {
    		_currentPath = _currentPath + "." + aKey;
    	}
    	_currentJSObject = previousCurrentJSObject[aKey];
    	var newObject = [self decodeObject];
    	_currentJSObject = previousCurrentJSObject;
    	_currentPath = previousPath;
    	return newObject;
    }
    return nil;
}

// we ignore the key (always passed as "CP.objects", and no corresponding key in the source js object)
- (id)_decodeArrayOfObjectsForKey:(CPString)aKey {

	var i = 0,
        count = _currentJSObject.length,
        array = [];
   	var previousCurrentJSObject = _currentJSObject;
   	var previousPath = _currentPath;
 
    for (; i < count; ++i) {
    
    	if(aKey!="CP.objects" && _currentPath.charAt(_currentPath.length-1)!=']' && _currentPath.charAt(_currentPath.length-1)!=')') {
     		_currentPath = previousPath + "." + aKey + "[" + i + "]";
		} else {
     		_currentPath = previousPath + "[" + i + "]"; // nested array in array or dictionary ("CP.objects" passed as aKey, ignored)
		}
    	_currentJSObject = previousCurrentJSObject[i];
    	array[i] = [self decodeObject];
    }   
   _currentJSObject = previousCurrentJSObject;
   _currentPath = previousPath;
   return array;
}

// we ignore the key (always passed as "CP.objects", and no corresponding key in the source js object)
- (id)_decodeDictionaryOfObjectsForKey:(CPString)aKey {

	 var dictionary = [CPDictionary dictionary];
     var previousCurrentJSObject = _currentJSObject;
     var previousPath = _currentPath;
     
     for(var _keyName in previousCurrentJSObject) {
     
     	if (_keyName!= "__objjClassName" && _keyName!="isa") {
     	
     		if(aKey!="CP.objects" && _currentPath.charAt(_currentPath.length-1)!=']' && _currentPath.charAt(_currentPath.length-1)!=')') {
     	  		_currentPath = previousPath + "." + aKey + "(" + _keyName + ")";
     		} else {
     	  		_currentPath = previousPath + "(" + _keyName + ")"; // nested dictionary in array or dictionary ("CP.objects" passed as aKey, ignored)
     		}
     		_currentJSObject = previousCurrentJSObject[_keyName];
     		[dictionary setValue:[self decodeObject] forKey:_keyName];
     	}
     }     
     _currentJSObject = previousCurrentJSObject;
     _currentPath = previousPath;
     return dictionary;
}

- (id)decodeObject {
	
	if(isArray(_currentJSObject)) {
		return [[CPArray alloc] initWithCoder:self];
	}
	// works for custom objects and dictionaries, but not for arrays
	var className = _currentJSObject["__objjClassName"]; // get the class name
	
	if(className==null) { // for string, number and boolean (no nested js object). Can also be a ref path ($ref:<path>), as a CPString
		if(_currentJSObject.isa.name=="CPString" && [_currentJSObject hasPrefix:REF_OBJECT_PREFIX]) {
			var refPath = [_currentJSObject substringFromIndex:REF_OBJECT_PREFIX.length];
			[pathToRef setValue:refPath forKey:_currentPath];
			return nil; // ref value object will be set in finishDecoding
		}
		return _currentJSObject;
	}
	
	if(className=="CPDate") {
  		return [self initDateWithJSObject:_currentJSObject];
  	}
	
    var classObject = objj_lookUpClass(className); // lookup the class object by name
    var newObject = [classObject alloc];

	if([classObject instancesRespondToSelector:@selector(initWithCoder:)]) { // also works for CPDictionary (corresponding js object has an __objjClassName field - not available for arrays)
		 
         return [newObject initWithCoder:self];

    } else {
    	for(var _propertyName in _currentJSObject) {
    		if (_propertyName != "__objjClassName" && _propertyName!="isa") { // the js object corresponding to the JSON string has an isa field ("string" value)
    			newObject[_propertyName] = [self decodeObjectForKey:_propertyName];
    		}
    	}
    	return newObject;
   }
}

@end


function isArray(obj) {

	return obj.constructor == Array;
}


