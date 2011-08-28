
/*
 * GorillaCmds.java
  *
  * Some helper class groups for use in the project
  * "Password Gorilla for Android"
  *
  * To be loaded for comile run add the following lines
  * to method "initInterp()" in file Interp.java :
  *   //  System.err.println("loading Gorilla cmds...");
  *   // Gorilla commands.
  *   // GorillaCmds.load(this);
  *
  * Author: Zbigniew Diaczyszyn 2011
  * Email: z_dot_dia_at_gmx_dot_de
*/

package org.hecl;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import java.io.*;

import org.hecl.IntThing;
import org.hecl.StringThing;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.Cipher;
import java.security.Security;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.bouncycastle.jce.provider.BouncyCastleProvider;


class GorillaCmds extends Operator {
  
  public static final int SHA256 = 1;
  public static final int HEX = 2;
  public static final int TWOFISHENCRYPT = 3;
  public static final int TWOFISHDECRYPT = 4;

  public byte[] hexDecode(String hex) throws Exception {
		// System.out.println("len" + hex.length());
    if ((hex.length() % 2) != 0)
      throw new IllegalArgumentException("Input string must contain an even number of characters");

    final byte result[] = new byte[hex.length()/2];
    final char enc[] = hex.toCharArray();
    for (int i = 0; i < enc.length; i += 2) {
      StringBuilder curr = new StringBuilder(2);
      curr.append(enc[i]).append(enc[i + 1]);
      result[i/2] = (byte) Integer.parseInt(curr.toString(), 16);
    }
    return result;
  }

  public String hexEncode(byte[] data) throws Exception {
    StringBuffer sb = new StringBuffer(4096);
    for (int i = 0; i < data.length; i++) {
           sb.append(Integer.toString((data[i] & 0xff) + 0x100, 16).substring(1));
          }
    return sb.toString();
          // String encoded = hexEncode(byteData);
  }
  
  public Thing operate(int cmd, Interp interp, Thing[] argv) throws HeclException {
    
    String str = argv[1].toString();
    StringBuffer sb = new StringBuffer(4096);
    

    switch (cmd) {

      case SHA256:
      // input str must be a hex encoded string
      // returns string hex coded
      // http://stackoverflow.com/questions/140131/convert-a-string-representation-of-a-hex-dump-to-a-byte-array-using-java
        try {
          MessageDigest md = MessageDigest.getInstance("SHA-256");
          
          byte[] decoded = hexDecode(str);
          md.update(decoded);
      
          byte[] digestResult = md.digest();
      
          return StringThing.create(hexEncode(digestResult));
        }

        catch (Exception e) {
          return StringThing.create(e.getMessage());
        }
        
      case HEX:
        // binary scan to Hex
        byte[] byteData = str.getBytes();
// System.out.println("strlen " + str.length());
// System.out.println("bytelen " + byteData.length);
        for (int i = 0; i < byteData.length ; i++) {
          sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
        }
        
        return StringThing.create(sb.toString());

      case TWOFISHENCRYPT:
      /* Syntax: twofish::encrypt message key */
      /* Todo Syntax: twofish::encrypt -ecb|-cbc message key */

        try {

					String key = argv[2].toString();
		
					byte[] strBytes = hexDecode(str);
					byte[] keyBytes = hexDecode(key);
 
					Security.addProvider(new BouncyCastleProvider());
					// System.out.println("sec " + Security.getProvider("BC"));

					SecretKey gorillaKey = new SecretKeySpec(keyBytes, "Twofish");

          Cipher cipher = Cipher.getInstance("Twofish/ECB/NoPadding", "BC");
        
					byte[] cipherText = new byte[strBytes.length];
					cipher.init(Cipher.ENCRYPT_MODE, gorillaKey);
	
					int ctLength = cipher.update(strBytes, 0, strBytes.length, cipherText, 0);
					
					ctLength += cipher.doFinal(cipherText, ctLength);
	
					return StringThing.create(hexEncode(cipherText));

				}

				catch (Exception e) {
					return StringThing.create("Error: " + e.getMessage());
				}

			case TWOFISHDECRYPT:
      /* Syntax: twofish::decrypt message key */
      /* Todo Syntax: twofish::encrypt -ecb|-cbc message key */

        try {

					String key = argv[2].toString();
		
					byte[] encodedBytes = hexDecode(str);
					byte[] keyBytes = hexDecode(key);
 					byte[] decodedBytes = new byte[encodedBytes.length];

					Security.addProvider(new BouncyCastleProvider());
					// System.out.println("sec " + Security.getProvider("BC"));

					SecretKey gorillaKey = new SecretKeySpec(keyBytes, "Twofish");
          Cipher cipher = Cipher.getInstance("Twofish/ECB/NoPadding", "BC");
					cipher.init(Cipher.DECRYPT_MODE, gorillaKey);
	
					int decodedLength = cipher.update(encodedBytes, 0, encodedBytes.length, decodedBytes, 0);
					decodedLength += cipher.doFinal(decodedBytes, decodedLength);
	
					return StringThing.create(hexEncode(decodedBytes));

				}

				catch (Exception e) {
					return StringThing.create("Error: " + e.getMessage());
				}
        
      default:
        throw new HeclException("Unknown Gorilla command '"
              + argv[1].toString() + "' with code '"
              + cmd + "'.");
    }
  }

  public static void load(Interp ip) throws HeclException {
    Operator.load(ip,cmdtable);
  }

  public static void unload(Interp ip) throws HeclException {
    Operator.unload(ip,cmdtable);
  }

  protected GorillaCmds(int cmdcode, int minargs, int maxargs) {
    super(cmdcode, minargs, maxargs);
  }

  private static Hashtable cmdtable = new Hashtable();
  
  static {
    cmdtable.put("sha256", new GorillaCmds(SHA256,1,1));
    cmdtable.put("hex", new GorillaCmds(HEX,1,1));
    cmdtable.put("twofish::encrypt", new GorillaCmds(TWOFISHENCRYPT,1,2));
    cmdtable.put("twofish::decrypt", new GorillaCmds(TWOFISHDECRYPT,1,2));
  }
}
