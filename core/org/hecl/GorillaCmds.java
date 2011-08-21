/*
	* GorillaCmds.java
	*
	* Some helper class groups for use in the project
	* "Password Gorilla for Android"
	*
	* To be loaded for comile run add the following lines
	* to method "initInterp()" in file Interp.java :
	* 	//	System.err.println("loading Gorilla cmds...");
	* 	// Gorilla commands.
	* 	// GorillaCmds.load(this);
	*
	* Author: Zbigniew Diaczyszyn 2011
	* Email: z_dot_dia_at_gmx_dot_de
*/

package org.hecl;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import org.hecl.IntThing;
import org.hecl.StringThing;


class GorillaCmds extends Operator {
	
	public static final int HEXSCANLE = 1;

	public Thing operate(int cmd, Interp interp, Thing[] argv) throws HeclException {
		String str = argv[1].toString();
		// StringBuffer sb = null;
		StringBuffer sb = new StringBuffer();

		switch (cmd) {

			case HEXSCANLE:
			// Binary scan to Hex Little Endian
			
				byte byteData[] = str.getBytes();

				for (int i = (byteData.length-1); i >= 0 ; i--) {
					sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
				}
				
				return StringThing.create(sb.toString());
/*
			NumberThing num = null;
			num = NumberThing.asNumber(argv[1]);
			
			return IntThing.create(num);
*/

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
		cmdtable.put("scanlehex", new GorillaCmds(HEXSCANLE,1,1));
	}
}
