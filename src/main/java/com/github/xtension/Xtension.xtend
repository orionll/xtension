package com.github.xtension

import java.util.Iterator

final class Xtension {
	private new() {
	}

	def static <T> RichIterator<T> rich(Iterator<T> iterator) {
		switch (iterator) {
			RichIterator<T> : iterator
			default : new RichIterator<T>(iterator)
		}
	}

	@Deprecated
	def static <T> RichIterator<T> rich(RichIterator<T> iterator) { iterator }
}