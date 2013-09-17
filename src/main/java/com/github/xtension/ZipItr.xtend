package com.github.xtension

import com.google.common.collect.AbstractIterator
import java.util.Iterator

package class ZipItr<T, U, R> extends AbstractIterator<R> {
	val Iterator<T> a
	val Iterator<U> b
	val (T, U) => R operator

	new(Iterator<T> a, Iterator<U> b, (T, U) => R operator) {
		this.a = a
		this.b = b
		this.operator = operator
	}

	override protected computeNext() {
		if (a.hasNext && b.hasNext) {
			operator.apply(a.next, b.next)
		} else {
			endOfData
		}
	}
}
