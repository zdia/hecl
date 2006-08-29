/*
 * Copyright (C) 2005, 2006 data2c GmbH (www.data2c.com)
 *
 * Author: Wolfgang S. Kechel - wolfgang.kechel@data2c.com
 *
 * J2ME version of java.awt.Dimension. 
 */
//#ifndef ant:j2se
package org.awt;

import org.awt.geom.Dimension2D;

/**
 * The <code>Dimension</code> class encapsulates the width and 
 * height of a component (in integer precision) in a single object. 
 * The class is 
 * associated with certain properties of components. Several methods 
 * defined by the <code>Component</code> class and the 
 * <code>LayoutManager</code> interface return a 
 * <code>Dimension</code> object. 
 * <p>
 * Normally the values of <code>width</code> 
 * and <code>height</code> are non-negative integers. 
 * The constructors that allow you to create a dimension do 
 * not prevent you from setting a negative value for these properties. 
 * If the value of <code>width</code> or <code>height</code> is 
 * negative, the behavior of some methods defined by other objects is 
 * undefined. 
 */
public class Dimension extends Dimension2D /*implements java.io.Serializable*/ {
    
    /**
     * The width dimension; negative values can be used. 
     *
     * @serial
     * @see #getSize
     * @see #setSize
     */
    public int width;

    /**
     * The height dimension; negative values can be used. 
     *
     * @serial
     * @see #getSize
     * @see #setSize
     */
    public int height;

    /** 
     * Creates an instance of <code>Dimension</code> with a width 
     * of zero and a height of zero. 
     */
    public Dimension() {
	this(0, 0);
    }

    /** 
     * Creates an instance of <code>Dimension</code> whose width  
     * and height are the same as for the specified dimension. 
     *
     * @param    d   the specified dimension for the 
     *               <code>width</code> and 
     *               <code>height</code> values
     */
    public Dimension(Dimension d) {
	this(d.width, d.height);
    }

    /** 
     * Constructs a <code>Dimension</code> and initializes
     * it to the specified width and specified height.
     *
     * @param width the specified width 
     * @param height the specified height
     */
    public Dimension(int width, int height) {
	this.width = width;
	this.height = height;
    }

    /**
     * Returns the width of this dimension in double precision.
     * @return the width of this dimension in double precision
     */
    public double getWidth() {
	return width;
    }

    /**
     * Returns the height of this dimension in double precision.
     * @return the height of this dimension in double precision
     */
    public double getHeight() {
	return height;
    }

    /**
     * Sets the size of this <code>Dimension</code> object to
     * the specified width and height in double precision.
     * Note that if <code>width</code> or <code>height</code>
     * are larger than <code>Integer.MAX_VALUE</code>, they will
     * be reset to <code>Integer.MAX_VALUE</code>.
     *
     * @param width  the new width for the <code>Dimension</code> object
     * @param height the new height for the <code>Dimension</code> object
     */
    public void setSize(double width, double height) {
	this.width = (int) Math.ceil(width);
	this.height = (int) Math.ceil(height);
    }

    /**
     * Gets the size of this <code>Dimension</code> object.
     * This method is included for completeness, to parallel the
     * <code>getSize</code> method defined by <code>Component</code>.
     *
     * @return   the size of this dimension, a new instance of 
     *           <code>Dimension</code> with the same width and height
     * @see      java.awt.Dimension#setSize
     * @see      java.awt.Component#getSize
     */
    public Dimension getSize() {
	return new Dimension(width, height);
    }	

    /**
     * Sets the size of this <code>Dimension</code> object to the specified size.
     * This method is included for completeness, to parallel the
     * <code>setSize</code> method defined by <code>Component</code>.
     * @param    d  the new size for this <code>Dimension</code> object
     * @see      java.awt.Dimension#getSize
     * @see      java.awt.Component#setSize
     */
    public void setSize(Dimension d) {
	setSize(d.width, d.height);
    }	

    /**
     * Sets the size of this <code>Dimension</code> object 
     * to the specified width and height.
     * This method is included for completeness, to parallel the
     * <code>setSize</code> method defined by <code>Component</code>.
     *
     * @param    width   the new width for this <code>Dimension</code> object
     * @param    height  the new height for this <code>Dimension</code> object
     * @see      java.awt.Dimension#getSize
     * @see      java.awt.Component#setSize
     */
    public void setSize(int width, int height) {
    	this.width = width;
    	this.height = height;
    }	

    /**
     * Checks whether two dimension objects have equal values.
     */
    public boolean equals(Object obj) {
	if (obj instanceof Dimension) {
	    Dimension d = (Dimension)obj;
	    return (width == d.width) && (height == d.height);
	}
	return false;
    }

    /**
     * Returns the hash code for this <code>Dimension</code>.
     *
     * @return    a hash code for this <code>Dimension</code>
     */
    public int hashCode() {
        int sum = width + height;
        return sum * (sum + 1)/2 + width;
    }

    /**
     * Returns a string representation of the values of this 
     * <code>Dimension</code> object's <code>height</code> and 
     * <code>width</code> fields. This method is intended to be used only 
     * for debugging purposes, and the content and format of the returned 
     * string may vary between implementations. The returned string may be 
     * empty but may not be <code>null</code>.
     * 
     * @return  a string representation of this <code>Dimension</code> 
     *          object
     */
    public String toString() {
	return "Dimension[w=" + width + ", h=" + height + "]";
    }
}
//#endif
