import Foundation

extension String
{
    func sha1() -> String
    {
        let data: NSData = dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)

        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)

        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))

        for byte in digest { output.appendFormat("%02x", byte) }

        return output
    }

    func sha1String() -> String
    {
        let data: NSData = dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)

        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)

        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH*2))

        for byte in digest { output.appendFormat("%c", byte) }

        return output
    }

    func MD5String() -> String
    {
        let data: NSData = dataUsingEncoding(NSUTF8StringEncoding)!

        var digest = [UInt8](count:Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)

        CC_MD5(data.bytes, CC_LONG(data.length), &digest);

        let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH*2))

        for byte in digest { output.appendFormat("%02x", byte) }

        return output
    }

}