<?php
    
    $authLevels = array( 'Anonymous Contributor' => 0,
                         'Contributor'           => 1,
                         'Editor'                => 2,
                         'Admin'                 => 3,
                         'Root'                  => 4, );
                       
    function roleForAuthLevel( $authLevel )
    {
        foreach( $authLevels as $role => $level )
        {
            if( $authLevel == $level ){ return $role; }
        }
        
        return "Unknown";
    }
?>
