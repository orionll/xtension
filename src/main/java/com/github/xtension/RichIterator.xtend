package com.github.xtension

import com.google.common.base.Optional
import java.util.Iterator
import java.util.List
import java.util.Set

import static extension com.github.xtension.IteratorExtensions.*

class RichIterator<T> implements Iterator<T> {
	val Iterator<T> iterator

	package new(Iterator<T> iterator) { this.iterator = iterator }

	def forEach((T) => void procedure) { iterator.forEach(procedure) }

	def forEach((T, int) => void procedure) { iterator.forEach(procedure) }

	def <R> RichIterator<R> map((T) => R function) { new RichIterator<R>(iterator.map(function)) }

	def T findFirst((T) => boolean predicate) { iterator.findFirst(predicate) }

	def T findLast((T) => boolean predicate) { iterator.findLast(predicate) }

	def T head() { iterator.head }

	def RichIterator<T> tail() { new RichIterator<T>(iterator.tail) }

	def T last() { iterator.last }

	def RichIterator<T> take(int count) { new RichIterator<T>(iterator.take(count)) }

	def RichIterator<T> drop(int count) { new RichIterator<T>(iterator.drop(count)) }

	def boolean exists((T) => boolean predicate) { iterator.exists(predicate) }

	def boolean forall((T) => boolean predicate) { iterator.forall(predicate) }

	def RichIterator<T> filter((T) => boolean predicate) { new RichIterator<T>(iterator.filter(predicate)) }

	def RichIterator<T> filter(Class<T> type) { new RichIterator<T>(iterator.filter(type)) }

	def RichIterator<T> filterNull() { new RichIterator<T>(iterator.filterNull) }

	def String join() { iterator.join }

	def String join(CharSequence separator) { iterator.join(separator) }

	def String join(CharSequence separator, (T) => CharSequence function) { iterator.join(separator, function) }

	def String join(CharSequence before, CharSequence separator, CharSequence after, (T) => CharSequence function) {
		iterator.join(before, separator, after, function)
	}

	def boolean elementsEqual(Iterator<?> other) { iterator.elementsEqual(other) }

	def boolean isEmpty() { iterator.isEmpty }

	def int size() { iterator.size }

	def T reduce((T, T) => T function) { iterator.reduce(function) }

	def <R> R fold(R seed, (R, T) => R function) { iterator.fold(seed, function) }

	// TODO return RichList
	def List<T> toList() { iterator.toList }

	// TODO return RichSet
	def Set<T> toSet() { iterator.toSet }

	def <R> RichIterator<R> flatMap((T) => Iterator<? extends R> function) { new RichIterator<R>(iterator.flatMap(function)) }

	def Optional<T> headOptional() { iterator.headOptional }

	def Optional<T> lastOptional() { iterator.lastOptional }

	def Optional<T> findFirstOptional((T) => boolean predicate) { iterator.findFirstOptional(predicate) }

	def int count((T) => boolean predicate) { iterator.count(predicate) }

	def <U, R> RichIterator<R> zip(Iterator<U> other, (T, U) => R operator) {
		new RichIterator<R>(iterator.zip(other, operator))
	}

	override hasNext() { iterator.hasNext }

	override next() { iterator.next }

	override remove() { iterator.remove }
}
