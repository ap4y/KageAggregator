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
            NSString* managedObjectModelPath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.momd", scheme]];
            //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:scheme withExtension:@"momd"];
            NSURL* modelURL = [NSURL fileURLWithPath:managedObjectModelPath isDirectory:NO];
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
        }
        
        return managedObjectModel;
    }
}

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

+ (NSArray*)requestResult:(NSFetchRequest*)request {
    NSError* err = nil;
    NSArray* result = [[self managedObjectContext] executeFetchRequest:request error:&err];
    
    if (err) {
        NSLog(@"error occuried %@", err.localizedDescription);
        return nil;
    }
    
    return result;
}

+ (id)requestFirstResult:(NSFetchRequest*)request {
    NSError* err = nil;
    NSArray* result = [[self managedObjectContext] executeFetchRequest:request error:&err];
    
    if (err || result.count == 0) {
        NSLog(@"error occuried %@ or empty result", err.localizedDescription);
        return nil;
    }
    
    return [result objectAtIndex:0];
}

+ (BOOL)save {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@", error.localizedDescription);
        return NO;
    }
    
    return YES;
}
@end
