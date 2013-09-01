package com.github.xtension

import java.io.Closeable

class CloseableExtensions {

	/**
	 * Provides a convenient syntax that ensures the correct use of {@code Closeable} resources
	 * (like {@code try-with-resources} in Java 7+ or {@code using} in C#).
	 *
	 * <p>Example of usage:
	 * <pre>
	 * val text = using(new FileReader('file.txt')) [
	 *   val buf = CharBuffer::allocate(1024)
   *   it.read(buf)
   *   buf.rewind.toString
   * ]
   * </pre>
	 */
	def static <T extends Closeable, R> R using(T resource, (T) => R procedure) {

		// This is kept for a case when a Throwable from close()
		// overwrites a Throwable from try
		var Throwable mainThrowable = null

		try {
			return procedure.apply(resource)
		} catch (Throwable t) {
			mainThrowable = t
			throw t
		} finally {
			if (mainThrowable == null) {
				resource.close
			} else {
				try {
					resource.close
				} catch (Throwable unused) {
					// ignore because mainThrowable is present
				}
			}
		}
	}
}
