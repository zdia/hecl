/* Copyright 2005 David N. Welton

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

package org.hecl;

import java.util.Hashtable;


/**
 * The <code>Properties</code> class is used to parse command line
 * arguments.  Its basic usage pattern is like so: a new Properties is
 * instantiated with default properties and values, then setProps is
 * called with argv.  At that point the rest of the command can go on,
 * and for every prop that's needed, it can be fetched with getProp.
 *
 * @author <a href="mailto:davidw@dedasys.com">David N. Welton</a>
 * @version 1.0
 */
class Properties {
    private Hashtable props;

    /**
     * Creates a new <code>Properties</code> instance with default
     * properties and their values.
     *
     * @param defaultprops an <code>Object[]</code> value
     */
    Properties (Object [] defaultprops) {
	props = new Hashtable();
	for (int i = 0; i < defaultprops.length; i+=2) {
	    props.put((String)defaultprops[i], (Thing)defaultprops[i+1]);
	}
    }

    /**
     * The <code>setProps</code> method sets properties with their
     * values from the command line argv.
     *
     * @param argv a <code>Thing[]</code> value
     * @param offset an <code>int</code> value
     */
    public void setProps(Thing []argv, int offset) {
	for(int i = offset; i < argv.length; i +=2) {
	    setProp(argv[i].toString(), argv[i+1]);
	}
    }

    /**
     * The <code>setProp</code> method sets a single property to some
     * value.
     *
     * @param name a <code>String</code> value
     * @param val a <code>Thing</code> value
     */
    public void setProp(String name, Thing val) {
	props.put(name.toLowerCase(), (Object)val);
    }

    /**
     * The <code>getProp</code> method fetches the value of a
     * property.
     *
     * @param name a <code>String</code> value
     * @return a <code>Thing</code> value
     */
    public Thing getProp(String name) {
	return (Thing)props.get(name);
    }
}