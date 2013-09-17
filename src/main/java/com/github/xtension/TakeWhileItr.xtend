package com.github.xtension

import com.google.common.collect.AbstractIterator
import java.util.Iterator

// TODO The returned iterator should support remove() if the
// delegate iterator supports it
package class TakeWhileItr<T> extends AbstractIterator<T> {
	val Iterator<T> delegate
	val (T) => boolean predicate

	new(Iterator<T> delegate, (T) => boolean predicate) {
		this.delegate = delegate
		this.predicate = predicate
	}

	override protected computeNext() {
		if (delegate.hasNext) {
			val elem = delegate.next
			if (predicate.apply(elem)) {
				elem
			} else {
				endOfData
			}
		} else {
			endOfData
		}
	}
}
