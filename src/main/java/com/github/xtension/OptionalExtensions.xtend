package com.github.xtension

import com.google.common.base.Optional

import static com.google.common.base.Preconditions.*

final class OptionalExtensions {

	private new() {
	}

	/**
	 * Returns an {@link Optional} containing the result of applying a function to the value of this
	 * {@code Optional} if it is nonempty. Otherwise returns an empty {@code Optional}.
	 */
	def static <T, U> Optional<U> map(Optional<T> optional, (T) => U function) {
		if (optional.present) {
			Optional::of(function.apply(optional.get))
		} else {
			Optional::absent
		}
	}

	/**
	 * Returns the result of applying a function to the value of this {@code Optional} if it is nonempty.
	 * Otherwise returns an empty {@code Optional}. Slightly different from {@link #map} in that the function
	 * is expected to return an {@code Optional}.
	 */
	def static <T, U> Optional<U> flatMap(Optional<T> optional, (T) => Optional<U> function) {
		if (optional.present) {
			checkNotNull(function.apply(optional.get))
	  } else {
			Optional::absent
		}
	}

	/**
	 * If this {@code Optional} is nonempty, invoke a procedure with the value, otherwise do nothing.
	 */	
	def static <T> void ifPresent(Optional<T> optional, (T) => void procedure) {
		if (optional.present) {
			procedure.apply(optional.get)
		}
	}
}
