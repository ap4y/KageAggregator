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
            //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:scheme withExtension:@"momd"];
            managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [NSArray arrayWithObject:[NSBundle bundleWithIdentifier:@"mycompany.KageParserUnitTest"]]] retain];
        }
        
        return managedObjectModel;
    }
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    @synchronized(self)
    {
        if (!persistentStoreCoordinator) {
            NSURL* applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", scheme]];            
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
        NSLog(@"error occeried %@", err.localizedDescription);
        return nil;
    }
    
    return result;
}

+ (id)requestFirstResult:(NSFetchRequest*)request {
    NSError* err = nil;
    NSArray* result = [[self managedObjectContext] executeFetchRequest:request error:&err];
    
    if (err || result.count == 0) {
        NSLog(@"error occeried %@", err.localizedDescription);
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
