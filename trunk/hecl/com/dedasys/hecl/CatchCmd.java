/* Copyright 2004 David N. Welton

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

package com.dedasys.hecl;

import java.util.*;

/**
 * <code>CatchCmd</code> implements the "catch" command.
 *
 * @author <a href="mailto:davidw@dedasys.com">David N. Welton</a>
 * @version 1.0
 */

class CatchCmd implements Command {

    public void cmdCode(Interp interp, Thing[] argv)
	throws HeclException {
	Thing result;
	int retval;
	try {
	    Eval.eval(interp, argv[1]);
	    result = interp.result;
	    retval = 0;
	} catch (HeclException e) {
	    result = e.getStack();
	    retval = 1;
	}

	if (argv.length == 3) {
	    interp.setVar(argv[2].toString(), result);
	}

	interp.setResult(IntThing.create(retval));
    }
}
