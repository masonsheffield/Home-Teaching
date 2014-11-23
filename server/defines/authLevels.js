var authLevels = { 'Anonymous Contributor' : 0,
                   'Contributor'           : 1,
                   'Editor'                : 2,
                   'Admin'                 : 3,
                   'Root'                  : 4 };
                                   
function roleForAuthLevel( authLevel )
{
    for( var role in authLevels )
    {
        if( authLevels[role] == authLevel ){ return role; }
    }
    
    return "Unknown";
}
