//
//  KageParserUnitTest.m
//  KageParserUnitTest
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageParserUnitTest.h"
#import "Anime.h"
#import "CoreDataHelper.h"

@implementation KageParserUnitTest

- (void)testKageParserWithNewAnime {
    Anime* anime = [[Anime alloc] initWithmanagedObjectContext:[CoreDataHelper managedObjectContext]];    
    _kageParser = [[[KageParser alloc] initWithAnime:anime] autorelease];    
    STAssertNotNil(_kageParser, @"Kage parser can`t be initialized from anime without baseId");
    
    anime.baseId = [NSNumber numberWithInt:3302];
    _kageParser = [[[KageParser alloc] initWithAnime:anime] autorelease];    
    STAssertFalse([anime.name isEqualToString:@"Ao no Exorcist"], @"Incorrect name of the anime or error during parsing");    
    STAssertFalse(anime.subtitles.count == 7, @"Incorrect quantity of subtitles"); 
}

@end
