//
//  CoreDataHelper.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

static NSString* scheme = @"KageData";

+ (NSManagedObjectModel *)managedObjectModel {
    static NSManagedObjectModel *managedObjectModel;
    
    @synchronized(self)
    {
        if (!managedObjectModel) {
            //NSString* managedObjectModelPath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.momd", scheme]];
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:scheme withExtension:@"momd"];
            //NSURL* modelURL = [NSURL fileURLWithPath:managedObjectModelPath isDirectory:NO];
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
        }
        
        return managedObjectModel;
    }
}

#if TARGET_OS_IPHONE
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    @synchronized(self)
    {
        if (!persistentStoreCoordinator) {
            //NSURL* applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSString* appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            //NSURL* applicationDocumentsDirectory = [NSURL URLWithString: appPath];
            appPath = [appPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", scheme]];
            NSURL *storeURL = [NSURL fileURLWithPath:appPath isDirectory:NO];            
            NSError *error = nil;
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }            
        }        
        return persistentStoreCoordinator;
    }
}
#else
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    @synchronized(self)
    {
        if (!persistentStoreCoordinator) {                        
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *applicationFilesDirectory = [libraryURL URLByAppendingPathComponent:scheme];
            NSError *error = nil;
            
            NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
            
            if (!properties) {
                BOOL ok = NO;
                if ([error code] == NSFileReadNoSuchFileError) {
                    ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
                }
                if (!ok) {
                    [[NSApplication sharedApplication] presentError:error];
                    return nil;
                }
            }
            else {
                if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
                    // Customize and localize this error.
                    NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
                    
                    [[NSApplication sharedApplication] presentError:error];
                    return nil;
                }
            }
            
            NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.storedata", scheme]];
            NSLog(@"store url %@", url.absoluteString);
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
                [[NSApplication sharedApplication] presentError:error];
                [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                return nil;
            }
        }        
        return persistentStoreCoordinator;
    }
}
#endif

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *managedObjectContext;
    
    @synchronized(self)
    {
        if (!managedObjectContext) {
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if (coordinator != nil)
            {
                managedObjectContext = [[NSManagedObjectContext alloc] init];
                [managedObjectContext setPersistentStoreCoordinator:coordinator];
            }
        }
        
        return managedObjectContext;
    }
}

+ (NSArray*)requestResult:(NSFetchRequest*)request managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSError* err = nil;
    NSArray* result = [managedObjectContext executeFetchRequest:request error:&err];
    
    if (err) {
        NSLog(@"error occuried %@", err.localizedDescription);
        return nil;
    }
    
    return result;
}

+ (id)requestFirstResult:(NSFetchRequest*)request managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSError* err = nil;
    
    NSArray* result = [managedObjectContext executeFetchRequest:request error:&err];
    
    if (err || result.count == 0) {
        NSLog(@"error occuried %@ or empty result", err.localizedDescription);
        return nil;
    }
    
    return [result objectAtIndex:0];
}

+ (BOOL)save:(NSManagedObjectContext*)managedObjectContext {
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error.localizedDescription);
        return NO;
    }
    
    return YES;
}
@end
