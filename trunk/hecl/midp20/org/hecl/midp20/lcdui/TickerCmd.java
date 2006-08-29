/*
 * Copyright 2005-2006
 * Wolfgang S. Kechel, data2c GmbH (www.data2c.com)
 * 
 * Author: Wolfgang S. Kechel - wolfgang.kechel@data2c.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.hecl.midp20.lcdui;

import javax.microedition.lcdui.Ticker;

import org.hecl.Command;
import org.hecl.HeclException;
import org.hecl.Interp;
import org.hecl.Properties;
import org.hecl.Thing;

public class TickerCmd extends OwnedThingCmd {
    public static final Command CREATE = new org.hecl.Command() {
	    public void cmdCode(Interp interp,Thing[] argv) throws HeclException {
		Properties p = WidgetInfo.defaultProps(Ticker.class);
		p.setProps(argv,1);
		Ticker w = new Ticker(p.getProp(WidgetInfo.NTEXT).toString());
		p.delProp(WidgetInfo.NTEXT);
		WidgetMap.addWidget(interp,null,w,new TickerCmd(interp,w,p));
	    }
	};

    private TickerCmd(Interp ip,Ticker t,Properties p) throws HeclException {
	super(ip,t,p);
    }
	
    public void cget(Interp ip,String optname) throws HeclException {
	Ticker ticker = (Ticker)getData();
	
	if(optname.equals(WidgetInfo.NTEXT)) {
	    ip.setResult(new Thing(ticker.getString()));
	    return;
	}
	super.cget(ip,optname);
    }

    public void cset(Interp ip,String optname,Thing optval) throws HeclException {
	Ticker ticker = (Ticker)getData();
	
	if(optname.equals(WidgetInfo.NTEXT)) {
	    ticker.setString(optval.toString());
	    return;
	}
	super.cset(ip,optname,optval);
    }
}
    
