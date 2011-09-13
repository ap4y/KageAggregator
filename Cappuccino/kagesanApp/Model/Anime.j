@implementation Anime : CPObject {
    CPNumber baseId    @accessors;
    CPData   image     @accessors;
    CPString name      @accessors;
    CPMutableArray  subtitles @accessors;
}

- (id)init {
    self = [super init];
    if (self) {
        subtitles = [[CPMutableArray alloc] init];
    }
    return self;
}

- (Subtitle)subtitleWithSrtId:(CPNumber)srtId {    
    CPLog("Check when will be values!!!");
    var srtIdPredicate = [CPPredicate predicateWithFormat: "srtId == " + [srtId stringValue]];
    var result = [subtitles filteredArrayUsingPredicate: srtIdPredicate];
    
    if ([result count] > 0)
        return [result objectAtIndex:0];
    else
        return nil;
}

@end

/*
 @implementation Anime (AnimeCategory)
 
 + (NSArray*)allAnime:(NSManagedObjectContext*)managedObjectContext {
 NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:managedObjectContext];
 [fetchRequest setEntity:entity];    
 
 return [CoreDataHelper requestResult:fetchRequest managedObjectContext:managedObjectContext];
 }
 
 + (Anime*)getAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
 NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext: managedObjectContext];
 [fetchRequest setEntity:entity];    
 //[fetchRequest setFetchBatchSize:20];
 
 NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"baseId == %i", baseId.integerValue];
 [fetchRequest setPredicate:libraryPredicate];
 
 return [CoreDataHelper requestFirstResult:fetchRequest managedObjectContext:managedObjectContext];
 }
 
 + (BOOL)addAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
 
 if ([self getAnime:baseId managedObjectContext:managedObjectContext]) {
 return NO;
 }            
 
 Anime* newAnime = [[Anime alloc] initWithmanagedObjectContext:managedObjectContext];  
 newAnime.baseId = baseId;
 
 return [newAnime reloadAnime];
 }
 
 + (BOOL)removeAnime:(Anime*)anime managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
 [managedObjectContext deleteObject:anime];
 
 return [CoreDataHelper save:managedObjectContext];
 }
 
 - (BOOL)reloadAnime {
 KageParser* kageParser = [[[KageParser alloc] initWithAnime:self] autorelease];
 
 if (!kageParser)
 return NO;
 
 [kageParser reloadData];
 
 return [CoreDataHelper save: kageParser.anime.managedObjectContext];
 }
 
 - (void)setIsWatched {
 for (Subtitle* subtitle in self.subtitles.allObjects) {
 [subtitle setUpdated:[NSNumber numberWithBool:NO]];        
 }        
 
 [CoreDataHelper save:self.managedObjectContext];
 }
 
 - (NSArray *)subtitlesBySeriesCount {
 NSSortDescriptor *sortDescriptorCount = [[[NSSortDescriptor alloc] initWithKey:@"seriesCount" ascending:YES] autorelease];
 
 NSArray* subtitles = [self.subtitles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorCount]];
 
 return subtitles;
 }
 
 - (NSArray*)subtitlesUpdated {
 NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:self.managedObjectContext];
 [fetchRequest setEntity:entity];    
 
 NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"anime == %@ and updated = YES", self];
 [fetchRequest setPredicate:libraryPredicate];
 
 return [CoreDataHelper requestResult:fetchRequest managedObjectContext:self.managedObjectContext];
 }
 
 @end
*/