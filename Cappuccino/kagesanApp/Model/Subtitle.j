@import "Anime.j"
@import "Group.j"

@implementation Subtitle : CPObject {
    CPNumber seriesCount @accessors;
    CPNumber srtId @accessors;
    CPNumber updated @accessors;
    Anime anime @accessors;
    Group fansubGroup @accessors;
}

@end
