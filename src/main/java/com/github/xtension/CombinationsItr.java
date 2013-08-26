package com.github.xtension;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Pair;

import com.google.common.collect.Lists;
import com.google.common.primitives.Ints;

class CombinationsItr<T> implements Iterator<List<T>> {

	// generating all nums such that:
	// (1) nums(0) + .. + nums(length-1) = n
	// (2) 0 <= nums(i) <= cnts(i), where 0 <= i <= cnts.length-1

	private final int n;
	private final List<T> elms;
	private final int[] cnts;
	private final int[] nums;
	private final List<Integer> offs;
	private boolean _hasNext = true;

	CombinationsItr(Iterable<T> iterable, int n) {
		this.n = n;
		Pair<List<T>, Pair<int[], int[]>> elmsCntsNums = init(iterable);
		this.elms = elmsCntsNums.getKey();
		this.cnts = elmsCntsNums.getValue().getKey();
		this.nums = elmsCntsNums.getValue().getValue();
		Iterable<Integer> offs = IterableExtensions.scan(
				Ints.asList(this.cnts), 0,
				new Function2<Integer, Integer, Integer>() {
					@Override
					public Integer apply(Integer p1, Integer p2) {
						return p1 + p2;
					}
				});

		this.offs = Lists.newArrayList(offs);
	}

	@Override
	public boolean hasNext() {
		return this._hasNext;
	}

	@Override
	public List<T> next() {
		if (!this.hasNext()) {
			throw new NoSuchElementException();
		}

		// Calculate this result
		List<T> res = Lists.newArrayListWithCapacity(this.n);
		for (int k = 0; k < this.nums.length; k++) {
			for (int j = 0; j < this.nums[k]; j++) {
				res.add(this.elms.get(this.offs.get(k) + j));
			}
		}

		// Prepare for the next call to next
		int idx = this.nums.length - 1;
		while ((idx >= 0) && (this.nums[idx] == this.cnts[idx])) {
			idx--;
		}

		idx = lastPositiveNum(this.nums, idx - 1);

		if (idx < 0) {
			this._hasNext = false;
		} else {
			int sum = 1;
			for (int i = idx + 1; i < this.nums.length; i++) {
				sum += this.nums[i];
			}

			this.nums[idx]--;
			for (int k = idx + 1; k < this.nums.length; k++) {
				this.nums[k] = Math.min(sum, this.cnts[k]);
				sum -= this.nums[k];
			}
		}

		return res;
	}

	/**
	 * Rearrange seq to newSeq a0a0..a0a1..a1...ak..ak such that seq.count(_ ==
	 * aj) == cnts(j)
	 *
	 * @return (newSeq,cnts,nums)
	 */
	private Pair<List<T>, Pair<int[], int[]>> init(Iterable<T> iterable) {
		final HashMap<T, Integer> m = new HashMap<T, Integer>();

		// e => (e, weight(e))
		Iterable<Pair<T, Integer>> map = org.eclipse.xtext.xbase.lib.IterableExtensions
				.map(iterable, new Function1<T, Pair<T, Integer>>() {
					@Override
					public Pair<T, Integer> apply(T e) {
						return Pair.of(e,
								MapExtensions.getOrElseUpdate(m, e, m.size()));
					}
				});

		Iterable<Pair<T, Integer>> sorted = org.eclipse.xtext.xbase.lib.IterableExtensions
				.sortBy(map, new Function1<Pair<T, Integer>, Integer>() {
					@Override
					public Integer apply(Pair<T, Integer> p) {
						return p.getValue();
					}
				});

		Pair<List<T>, List<Integer>> esIs = IterableExtensions.unzip(sorted);
		List<T> elms = esIs.getKey();
		List<Integer> is = esIs.getValue();

		int[] cnts = new int[m.size()];
		for (int i : is) {
			cnts[i]++;
		}

		int[] nums = new int[cnts.length];

		int r = this.n;
		for (int k = 0; k < nums.length; k++) {
			nums[k] = Math.min(r, cnts[k]);
			r -= nums[k];
		}

		return Pair.of(elms, Pair.of(cnts, nums));
	}

	private static int lastPositiveNum(int[] nums, int end) {
		int i = 0;
		int last = -1;

		for (int num : nums) {
			if (i > end) {
				return last;
			}
			if (num > 0) {
				last = i;
			}

			i++;
		}

		return last;
	}

	@Override
	public void remove() {
		throw new UnsupportedOperationException();
	}
}
