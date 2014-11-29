import Foundation

infix operator ~> {}
 
func ~> <T> (first:() -> T?, second:(result: T?) -> Void) -> Void
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    { () -> Void in
        var result: T? = first()
        
        dispatch_async(dispatch_get_main_queue(),
        { () -> Void in
            second(result: result)
        })
    })
}