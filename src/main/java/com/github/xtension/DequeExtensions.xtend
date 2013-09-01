package com.github.xtension

import java.util.Deque

final class DequeExtensions {

	private new() {
	}

	def static void trimStart(Deque<?> deque, int n) {
		for (i : 0 ..< n) {
			deque.removeFirst
		}
	}

	def static void trimEnd(Deque<?> deque, int n) {
		for (i : 0 ..< n) {
			deque.removeLast
		}
	}
}
