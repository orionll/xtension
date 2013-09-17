package com.github.xtension

import com.google.common.collect.AbstractIterator
import java.util.Iterator

package class ScanItr<T, U> extends AbstractIterator<U> {
	val Iterator<T> delegate
	val (U, T) => U function
	var U value
	var seedReturned = false

	new(Iterator<T> delegate, U seed, (U, T) => U function) {
		this.delegate = delegate
		this.function = function
		value = seed
	}

	override protected computeNext() {
		if (!seedReturned) {
			seedReturned = true
			value
		} else if (delegate.hasNext) {
			value = function.apply(value, delegate.next)
			value
		} else {
			endOfData
		}
	}
}
