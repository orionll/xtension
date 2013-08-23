package com.github.xtension

import java.util.Map

final class MapExtensions {

	private new() {
	}

	/**
	 * Returns the value associated with a key, or a default value if the key is not contained in the map.
	 */
	def static <K, V1, V extends V1> V1 getOrElse(Map<K, V> map, K key, V1 defaultValue) {
		if (map.containsKey(key)) {
			map.get(key)
		} else {
			defaultValue
		}
	}

	/**
	 * Returns the value associated with a key. If the given key is not contained in the map,
	 * stores a default value with the key in the map and returns that value.
	 */
	def static <K, V> V getOrElseUpdate(Map<K, V> map, K key, V defaultValue) {
		if (map.containsKey(key)) {
			map.get(key)
		} else {
			map.put(key, defaultValue)
			defaultValue
		}
	}
}