// Hashing String with SHA-256

// It will use SHA-256 hashing algorithm to generate a hash value for a password in the argv
// Usage: sha256 password

// package org.hecl.Sha256;

import org.hecl.Command;
import org.hecl.HeclException;
import org.hecl.Interp;
import org.hecl.Thing;
import org.hecl.StringThing;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

class Sha256Cmd implements Command {

	protected StringThing arg;
	
	public Thing cmdCode(Interp interp, Thing[] argv) throws HeclException {

		// String password = "123456";
		String password = argv[1].toString();
		// System.out.println("argv1: " + password);
		try
		{
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			md.update(password.getBytes());
	
			byte byteData[] = md.digest();
	
			//convert the byte to hex format method 1
			StringBuffer sb = new StringBuffer();
			for (int i = 0; i < byteData.length; i++) {
			 sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
			}
	
			return StringThing.create(sb.toString());
		}
		catch ( NoSuchAlgorithmException nsae )
		{ 
				System.out.println("Algorithm SHA256 does not exist");
    }
		return null;
	}
}
 
/*

Output checks

Hex format : 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
Report from Internet
						 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
Report from Tcl:
% ::sha2::sha256 123456
             8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
*/

/*
private static String convertToHex(byte[] data)
    {
        StringBuffer buf = new StringBuffer();
 
        for (int i = 0; i < data.length; i++)
        {
            int halfbyte = (data[i] >>> 4) & 0x0F;
            int two_halfs = 0;
            do
            {
                if ((0 <= halfbyte) && (halfbyte <= 9))
                    buf.append((char) ('0' + halfbyte));
                else
                    buf.append((char) ('a' + (halfbyte - 10)));
                halfbyte = data[i] & 0x0F;
            }
            while(two_halfs++ < 1);
        }
        return buf.toString();
    }

convertToHex(sha1hash);

*/

/*
 * Time measurement
 * 
time {set i 0; while { < $i 100 } {sha256 123456;	incr $i } }
*/
/* tcl
time {set i 0;while { $i < 100 } {:::sha2::sha256 123456; incr i } }
*/

//convert the byte to hex format method 2
/*
			StringBuffer hexString = new StringBuffer();
			for (int i=0;i<byteData.length;i++) {
				String hex=Integer.toHexString(0xff & byteData[i]);
					if(hex.length()==1) hexString.append('0');
					hexString.append(hex);
			}
			System.out.println("Hex format method 2: " + hexString.toString());
*/
