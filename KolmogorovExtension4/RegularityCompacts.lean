import Mathlib.Topology.MetricSpace.Polish
import Mathlib.Topology.MetricSpace.Metrizable
import Mathlib.MeasureTheory.Measure.Regular
import Mathlib.Logic.Denumerable
import KolmogorovExtension4.AuxLemmas

--#align_import regularity_compacts

open Set MeasureTheory

open scoped ENNReal Topology BigOperators NNReal

section Misc

variable {α : Type _}

namespace Set

-- actually not used anymore
theorem monotone_iUnion {s : ℕ → Set α} (hs : Monotone s) (n : ℕ) : (⋃ m ≤ n, s m) = s n := by
  apply subset_antisymm
  · exact iUnion_subset fun m => iUnion_subset fun hm => hs hm
  · exact subset_iUnion_of_subset n (subset_iUnion_of_subset le_rfl subset_rfl)

-- actually not used anymore
theorem antitone_iInter {s : ℕ → Set α} (hs : Antitone s) (n : ℕ) : (⋂ m ≤ n, s m) = s n := by
  apply subset_antisymm
  · exact iInter_subset_of_subset n (iInter_subset _ le_rfl)
  · exact subset_iInter fun i => subset_iInter fun hin => hs hin

theorem eq_iInter_iInter {s : ℕ → Set α} : (⋂ n, s n) = ⋂ (n : ℕ) (m : ℕ) (_ : m ≤ n), s m := by
  ext x; simp only [Set.mem_iInter]; exact ⟨fun h _ k _ => h k, fun h i => h i i le_rfl⟩

end Set

namespace Function

/-- For some set s in the domain and S' in the codomain of f, assume S' ⊆ f '' s.
Then, there is s' ⊆ s with S' = f '' s'. -/
theorem subset_image {α β : Type _} {f : α → β} {s : Set α} {S' : Set β} (hS' : S' ⊆ f '' s) :
    ∃ (s' : Set α) (_ : s' ⊆ s), f '' s' = S' := by
  refine ⟨f ⁻¹' S' ∩ s, Set.inter_subset_right _ _, ?_⟩
  ext x
  simp only [mem_image, mem_inter_iff, mem_preimage]
  constructor
  · rintro ⟨y, ⟨hfy_mem, _⟩, rfl⟩
    exact hfy_mem
  · intro h
    obtain ⟨y, hy_mem, rfl⟩ : x ∈ f '' s := hS' h
    exact ⟨y, ⟨h, hy_mem⟩, rfl⟩

example (S : Set α) (a x : α) (h : x ∈ S) (h' : a = x) : (a ∈ S) := by
  rwa [Set.mem_def, h'] at *

/-- For some set s in the domain and a finset S' in the codomain of f, assume S' ⊆ f '' s.
Then, there is a finset s' ⊆ s with S' = f '' s'. -/
theorem subset_image_finset {α β : Type _} {f : α → β} {s : Set α} {S' : Finset β}
    (hS'1 : ↑S' ⊆ f '' s) : ∃ (s' : Finset α) (_ : ↑s' ⊆ s), f '' s' = S' := by
  classical
  have h : ∀ x ∈ S', ∃ y : α, y ∈ s ∧ f y = x := fun x hx => (mem_image f s _).1 (hS'1 hx)
  choose g hg using h
  let g' : S' → α := fun x => g x x.2
  refine ⟨(range g').toFinset, ?_, ?_⟩
  · intro x
    simp only [toFinset_range, Finset.univ_eq_attach, Finset.coe_image, mem_image, Finset.mem_coe, Finset.mem_attach,
      true_and, Subtype.exists, forall_exists_index]
    rintro y H rfl
    exact (hg y H).1
  · ext1 x
    simp only [toFinset_range, Finset.univ_eq_attach, Finset.coe_image, mem_image, Finset.mem_coe,
      Finset.mem_attach, true_and_iff, Finset.exists_coe]
    constructor
    · rintro ⟨y, ⟨x, hx_mem, rfl⟩, rfl⟩
      rwa [(hg x hx_mem).2]
    · intro h
      obtain ⟨y, _, rfl⟩ : x ∈ f '' s := hS'1 h
      exact ⟨g (f y) h, ⟨f y, h, rfl⟩, (hg (f y) h).2⟩

/-- Same as subset_image, but assuming that S' is finite.
Then, s' can be chosen to be finite, too. -/
theorem subset_image_fintype {α β : Type _} {f : α → β} {s : Set α} {S' : Set β}
    (hS'1 : S' ⊆ f '' s) (hS'2 : S'.Finite) :
    ∃ (s' : Set α) (_ : s' ⊆ s) (_ : s'.Finite), f '' s' = S' := by
  obtain ⟨s', hs', hfs'⟩ :=
    @subset_image_finset α β f s hS'2.toFinset (by rwa [Finite.coe_toFinset])
  refine' ⟨s', hs', Finset.finite_toSet s', _⟩
  rwa [Finite.coe_toFinset] at hfs' 

end Function

namespace ENNReal

theorem tendsto_atTop_zero_iff_of_antitone (f : ℕ → ℝ≥0∞) (hf : Antitone f) :
    Filter.Tendsto f Filter.atTop (𝓝 0) ↔ ∀ ε, 0 < ε → ∃ n : ℕ, f n ≤ ε := by
  rw [ENNReal.tendsto_atTop_zero]
  refine ⟨fun h => fun ε hε => ?_, fun h => fun ε hε => ?_⟩
  · obtain ⟨n, hn⟩ := h ε hε
    exact ⟨n, hn n le_rfl⟩
  · obtain ⟨n, hn⟩ := h ε hε
    exact ⟨n, fun m hm => (hf hm).trans hn⟩

theorem tendsto_atTop_of_antitone (f : ℕ → ℝ≥0∞) (hf : Antitone f) :
    Filter.Tendsto f Filter.atTop (𝓝 0) ↔ ∀ ε, 0 < ε → ∃ n : ℕ, f n < ε := by
  rw [ENNReal.tendsto_atTop_zero_iff_of_antitone f hf]
  constructor <;> intro h ε hε
  have hε' : (min 1 (ε / 2)) > 0
  · simp only [ge_iff_le, gt_iff_lt, lt_min_iff, zero_lt_one, div_pos_iff, ne_eq, and_true,
      true_and] 
    intro g
    exact hε.ne g.symm
  · obtain ⟨n, hn⟩ := h (min 1 (ε / 2)) hε'
    · refine' ⟨n, hn.trans_lt _⟩
      by_cases hε_top : ε = ∞
      · rw [hε_top]
        exact (min_le_left _ _).trans_lt ENNReal.one_lt_top
      refine (min_le_right _ _).trans_lt ?_
      rw [ENNReal.div_lt_iff (Or.inr hε.ne') (Or.inr hε_top)]
      conv_lhs => rw [← mul_one ε]
      rw [ENNReal.mul_lt_mul_left hε.ne' hε_top]
      norm_num
  · obtain ⟨n, hn⟩ := h ε hε
    exact ⟨n, hn.le⟩ 

end ENNReal

namespace NNReal

theorem isOpen_Ico_zero {b : NNReal} : IsOpen (Set.Ico 0 b) := by 
  rw [← bot_eq_zero, Ico_bot];
  exact isOpen_Iio

/-- Given some x > 0, there is a sequence of positive reals summing to x. -/
theorem exists_seq_pos_summable_eq (x : ℝ≥0) (hx : 0 < x) :
    ∃ f : ℕ → ℝ≥0, (∀ n, 0 < f n) ∧ Summable f ∧ ∑' n, f n = x := by
  use fun n : ℕ => x / 2 / 2 ^ n
  constructor
  · intro n
    positivity
  have h : ∑' n : ℕ, x / 2 / 2 ^ n = x := by
    rw [← NNReal.eq_iff, NNReal.coe_tsum]
    push_cast [(· ∘ ·), NNReal.coe_div]
    rw [tsum_geometric_two' (x : ℝ)]
  refine' ⟨_, h⟩
  by_contra h1
  obtain h2 := tsum_eq_zero_of_not_summable h1
  rw [h] at h2 
  apply hx.ne
  rw [h2]

/-- Given some x > 0, there is a sequence of positive reals summing to something less than x.
This is needed in several lemmas in measure theory. -/
theorem exists_seq_pos_summable_lt (x : ℝ≥0) (hx : 0 < x) :
    ∃ f : ℕ → ℝ≥0, (∀ n, 0 < f n) ∧ Summable f ∧ ∑' n, f n < x := by
  cases' NNReal.exists_seq_pos_summable_eq (x / 2) (half_pos hx) with f hf
  refine ⟨f, hf.1, ?_, ?_⟩
  · rcases hf with ⟨_, hf2, _⟩
    exact hf2
  · rcases hf with ⟨_, _, hf3⟩
    rw [hf3]
    exact NNReal.half_lt_self (ne_of_gt hx)

end NNReal

end Misc

universe u

variable {α : Type u}

section MeasureTheory

namespace MeasureTheory

variable [MeasurableSpace α]

/-- Some version of continuity of a measure in the emptyset using a decreasing sequence of sets. -/
theorem cont_at_empty_of_measure (m : Measure α) [IsFiniteMeasure m] (s : ℕ → Set α)
    (hs1 : ∀ n, MeasurableSet (s n)) (hs2 : Antitone s) (hs3 : (⋂ n, s n) = ∅) :
    Filter.Tendsto (fun n => m (s n)) Filter.atTop (𝓝 0) := by
  convert MeasureTheory.tendsto_measure_iInter hs1 hs2 _
  · rw [hs3]; exact measure_empty.symm
  · exact ⟨0, measure_ne_top m _⟩

theorem cont_at_empty_of_measure' (m : Measure α) [IsFiniteMeasure m] (s : ℕ → Set α)
    (hs1 : ∀ n, MeasurableSet (s n)) (hs2 : Antitone s) (hs3 : (⋂ n, s n) = ∅) :
    ∀ ε, 0 < ε → ∃ n, m (s n) < ε :=
  (ENNReal.tendsto_atTop_of_antitone (fun n => m (s n)) fun _ _ h12 => measure_mono (hs2 h12)).1
    (cont_at_empty_of_measure m s hs1 hs2 hs3)

/-- Some version of continuity of a measure in the emptyset using the intersection along a set of
sets. -/
theorem continuous_at_emptyset_inter (m : Measure α) [IsFiniteMeasure m] (S : Set (Set α))
  (hS : Countable S) (hS2 : ∀ s ∈ S, MeasurableSet s) (hS3 : ⋂₀ S = ∅) {ε : ℝ≥0∞} (hε : 0 < ε) :
  ∃ (S' : Set (Set α)) (_ : S'.Finite) (_ : S' ⊆ S), m (⋂₀ S') < ε := by
  simp only [countable_coe_iff] at hS  
  cases' (fintypeOrInfinite S) with hS1 hS1
  · use! S, hS1, (by rfl)
    rw [hS3, measure_empty]
    exact hε
  · have hS' : Denumerable S :=
      @Denumerable.ofEncodableOfInfinite S (Set.Countable.toEncodable hS) hS1
    let e : S ≃ ℕ := Denumerable.eqv S
    let u n := ((e.symm n) : Set α)
    have hu_range : range u = S := by
      change range (Subtype.val ∘ e.symm) = S
      rw [range_comp, Equiv.range_eq_univ]
      simp only [image_univ, Subtype.range_coe_subtype, setOf_mem_eq]
    let s n := (Set.Accumulate (fun m => ((u m)ᶜ : Set α)) n)ᶜ  
    have hs1 : ∀ n, MeasurableSet (s n) := by
      intro n
      apply MeasurableSpace.measurableSet_compl
      refine MeasurableSet.iUnion (fun b ↦ MeasurableSet.iUnion (fun _ ↦ ?_))
      simp only [Denumerable.decode_eq_ofNat, Option.some.injEq, MeasurableSet.compl_iff]
      apply hS2 ↑(Denumerable.ofNat (↑S) b)
      simp only [Denumerable.decode_eq_ofNat, Option.some.injEq, Subtype.coe_prop]
    have hs2 : Antitone s := by
      intro n1 n2 h12
      simp only [le_eq_subset, compl_subset_compl]
      apply Set.monotone_accumulate h12 
    have hs3 : ⋂ (n : ℕ), s n = ∅ := by 
      simp only
      rw [Iff.symm compl_univ_iff] 
      simp only [Denumerable.decode_eq_ofNat, Option.some.injEq,  compl_iInter, compl_compl]
      rw [Set.iUnion_accumulate, ← compl_iInter, ← Iff.symm compl_univ_iff, ←hS3,
        ← Set.sInter_range]
      rw [hu_range]
    obtain ha := cont_at_empty_of_measure' m s hs1 hs2 hs3
    specialize ha ε hε
    cases' ha with n hn
    let S' := u '' {m : ℕ | m ≤ n}
    have hS' : Fintype S' := by 
      classical 
      exact {m : ℕ | m ≤ n}.fintypeImage u
    have SN : S = u '' univ :=  by
      rw [Set.image_univ, hu_range]
    have S'_sub : S' ⊆ S := by
      rw [SN]
      simp only [image_univ, image_subset_iff, preimage_range, subset_univ]
    have h0 : (⋂₀ S') = s n := by 
      simp only [Denumerable.decode_eq_ofNat, Option.some.injEq, sInter_image, mem_setOf_eq]
      rw [Set.accumulate_def]
      simp only [Denumerable.decode_eq_ofNat, Option.some.injEq, compl_iUnion, compl_compl]
    use! S', hS', S'_sub
    rw [h0]
    exact hn 

end MeasureTheory

end MeasureTheory

section RelativelyCompact

-- A set is relatively compact iff its closure is compact
example [TopologicalSpace α] (s t : Set α) (hs : IsCompact s) (ht : IsClosed t) :
    IsCompact (s ∩ t) :=
  IsCompact.inter_right hs ht

theorem of_compact [TopologicalSpace α] [T2Space α] {s : Set α} (hs : IsCompact s) :
    IsCompact (closure s) := by rwa [IsClosed.closure_eq hs.isClosed] 

end RelativelyCompact

section Topology

namespace UniformSpace

def interUnionBalls (s' : ℕ → Set α) (V : ℕ → Set (α × α)) : Set α :=
  ⋂ n : ℕ, ⋃ x ∈ s' n, UniformSpace.ball x (Prod.swap ⁻¹' V n)

theorem totallyBounded_interUnionBalls [UniformSpace α] {p : ℕ → Prop} {U : ℕ → Set (α × α)}
    (H : (uniformity α).HasBasis p U) (s' : ℕ → Finset α) :
    TotallyBounded (interUnionBalls (fun n => ↑(s' n)) U) :=
  by
  rw [Filter.HasBasis.totallyBounded_iff H]
  intro i _
  let A := interUnionBalls (fun n => (s' n : Set α)) U
  have hA2 : A ⊆ ⋃ (x : α) (_ : x ∈ s' i), UniformSpace.ball x (Prod.swap ⁻¹' U i) :=
    by
    let B : ℕ → Set α := fun n => ⋃ (x : α) (_ : x ∈ s' n), UniformSpace.ball x (Prod.swap ⁻¹' U n)
    change A ⊆ B i
    intro x hx
--    simp only [A] at hx 
    exact Set.mem_iInter.1 hx i 
  refine' ⟨s' i, Finset.finite_toSet (s' i), _⟩
  simp only [Finset.mem_coe]
  simp only [UniformSpace.ball] at hA2 
  intro x hx
  specialize hA2 hx
  let B x := Prod.mk x ⁻¹' (Prod.swap ⁻¹' U i)
  let C x := {y : α | (y, x) ∈ U i}
  have h : B = C := by ext x y; rfl
  change x ∈ ⋃ (x : α) (_ : x ∈ s' i), C x
  change x ∈ ⋃ (x : α) (_ : x ∈ s' i), B x at hA2 
  rw [← h]
  exact hA2

/-- The construction of inter_union_balls is used to have a relatively compact set, as shown here.-/
theorem isCompact_closure_interUnionBalls [UniformSpace α] {p : ℕ → Prop} {U : ℕ → Set (α × α)}
    (H : (uniformity α).HasBasis p U) [CompleteSpace α] (s' : ℕ → Finset α) :
    IsCompact (closure (interUnionBalls (fun n => (s' n : Set α)) U)) :=
  by
  rw [isCompact_iff_totallyBounded_isComplete]
  refine' ⟨_, IsClosed.isComplete isClosed_closure⟩
  apply TotallyBounded.closure
  exact totallyBounded_interUnionBalls H s'

end UniformSpace

end Topology

namespace MeasureTheory

variable [MeasurableSpace α]

theorem innerRegular_isCompact_is_rel_compact [TopologicalSpace α] (μ : Measure α)
    (h : μ.InnerRegular (fun s => IsCompact (closure s)) IsClosed) :
    μ.InnerRegular IsCompact IsClosed := by
  intro A hA r hr
  rcases h hA r hr with ⟨K, ⟨hK1, hK2, hK3⟩⟩
  exact ⟨closure K, closure_minimal hK1 hA, hK2, hK3.trans_le (measure_mono subset_closure)⟩

theorem innerRegular_isCompact_is_rel_compact_iff [TopologicalSpace α] [T2Space α] (μ : Measure α) :
    μ.InnerRegular IsCompact IsClosed ↔ μ.InnerRegular (IsCompact ∘ closure) IsClosed :=
  by
  refine' ⟨fun h A hA r hr => _, innerRegular_isCompact_is_rel_compact μ⟩
  rcases h hA r hr with ⟨K, ⟨hK1, hK2, hK3⟩⟩
  use closure K
  refine' ⟨closure_minimal hK1 hA, _, _⟩
  simp only [closure_closure, Function.comp_apply]; exact of_compact hK2
  apply lt_of_lt_of_le hK3 (measure_mono subset_closure)

theorem innerRegular_of_univ [TopologicalSpace α] [OpensMeasurableSpace α] (μ : Measure α)
    (hμ : ∀ (ε : ℝ≥0∞) (hε : 0 < ε), ∃ (K : _) (_ : IsCompact (closure K)), μ (Kᶜ) < ε)
    [IsFiniteMeasure μ] : μ.InnerRegular (IsCompact ∘ closure) IsClosed :=
  by
  intro A hA r hr
  obtain ⟨K, hK_relatively_compact, hKA, h_lt⟩ :
    ∃ (K : _) (_ : IsCompact (closure K)) (_ : K ⊆ A), μ (A \ closure K) < μ A - r :=
    by
    obtain ⟨K', hK'_relatively_compact, hK'_lt⟩ := hμ (μ A - r) (tsub_pos_of_lt hr)
    refine' ⟨closure K' ∩ A, _, ⟨inter_subset_right _ _, _⟩⟩
    · rw [IsClosed.closure_eq]
      exact hK'_relatively_compact.inter_right hA
      apply IsClosed.inter isClosed_closure hA
    refine' (measure_mono fun x => _).trans_lt hK'_lt
    simp only [diff_inter_self_eq_diff, mem_diff, mem_compl_iff, and_imp, imp_self, imp_true_iff]
    rw [IsClosed.closure_eq (IsClosed.inter isClosed_closure hA)]
    refine' fun hA hK hK' => hK _
    exact ⟨subset_closure hK', hA⟩
  refine' ⟨closure K, closure_minimal hKA hA, _, _⟩
  · simp only [closure_closure, Function.comp_apply]
    exact hK_relatively_compact
  rw [measure_diff (closure_minimal hKA hA) _ (measure_ne_top μ _)] at h_lt 
  exact lt_of_tsub_lt_tsub_left h_lt
  exact measurableSet_closure

theorem innerRegular_of_univ' [TopologicalSpace α] [OpensMeasurableSpace α] (μ : Measure α)
    (hμ : ∀ (ε : ℝ≥0) (hε : 0 < ε), ∃ (K : _) (_ : IsCompact (closure K)), μ (Kᶜ) < ε)
    [IsFiniteMeasure μ] : μ.InnerRegular (IsCompact ∘ closure) IsClosed :=
  by
  refine' innerRegular_of_univ μ fun ε hε => _
  by_cases h_top : ε = ∞
  · rw [h_top]
    exact ⟨∅, by rw [closure_empty]; exact isCompact_empty, measure_lt_top _ _⟩
  specialize hμ ε.toNNReal (ENNReal.toNNReal_pos hε.ne' h_top)
  obtain ⟨K, hK_compact, hK⟩ := hμ
  rw [ENNReal.coe_toNNReal h_top] at hK 
  refine' ⟨K, hK_compact, hK⟩

theorem innerRegular_isCompact_isClosed_of_univ [TopologicalSpace α] [OpensMeasurableSpace α]
    (μ : Measure α) (hμ : ∀ (ε : ℝ≥0∞) (hε : 0 < ε), ∃ K, IsCompact K ∧ IsClosed K ∧ μ (Kᶜ) < ε)
    [IsFiniteMeasure μ] : μ.InnerRegular (fun s => IsCompact s ∧ IsClosed s) IsClosed :=
  by
  intro A hA r hr
  obtain ⟨K, hK_compact, hK_closed, hKA, h_lt⟩ :
    ∃ K, IsCompact K ∧ IsClosed K ∧ K ⊆ A ∧ μ (A \ K) < μ A - r :=
    by
    obtain ⟨K', hK'_compact, hK'_closed, hK'_lt⟩ := hμ (μ A - r) (tsub_pos_of_lt hr)
    refine' ⟨K' ∩ A, _, hK'_closed.inter hA, ⟨inter_subset_right _ _, _⟩⟩
    · exact hK'_compact.inter_right hA
    refine' (measure_mono fun x => _).trans_lt hK'_lt
    simp only [diff_inter_self_eq_diff, mem_diff, mem_compl_iff, and_imp, imp_self, imp_true_iff]
  refine' ⟨K, hKA, ⟨hK_compact, hK_closed⟩, _⟩
  rw [measure_diff hKA _ (measure_ne_top μ _)] at h_lt 
  exact lt_of_tsub_lt_tsub_left h_lt
  exact IsClosed.measurableSet hK_closed 

theorem innerRegular_isCompact_isClosed_of_univ' [TopologicalSpace α] [OpensMeasurableSpace α]
    (μ : Measure α) (hμ : ∀ (ε : ℝ≥0) (hε : 0 < ε), ∃ K, IsCompact K ∧ IsClosed K ∧ μ (Kᶜ) < ε)
    [IsFiniteMeasure μ] : μ.InnerRegular (fun s => IsCompact s ∧ IsClosed s) IsClosed :=
  by
  refine' innerRegular_isCompact_isClosed_of_univ μ fun ε hε => _
  by_cases h_top : ε = ∞
  · rw [h_top]
    exact ⟨∅, isCompact_empty, isClosed_empty, measure_lt_top _ _⟩
  specialize hμ ε.toNNReal (ENNReal.toNNReal_pos hε.ne' h_top)
  obtain ⟨K, hK_compact, hK⟩ := hμ
  rw [ENNReal.coe_toNNReal h_top] at hK 
  refine' ⟨K, hK_compact, hK⟩

/-- Every measure on a compact space is regular with respect to relatively compact sets. -/
theorem innerRegular_isCompact_isClosed_of_compactSpace [TopologicalSpace α] [CompactSpace α]
    [OpensMeasurableSpace α] (P : Measure α) [IsFiniteMeasure P] :
    P.InnerRegular (IsCompact ∘ closure) IsClosed :=
  by
  refine' innerRegular_of_univ' P _
  refine' fun ε hε => ⟨univ, by rw [closure_univ]; exact isCompact_univ, _⟩
  simpa only [Set.compl_univ, MeasureTheory.measure_empty, ENNReal.coe_pos]

theorem Inter_iUnion_uniform_balls_measure (m : Measure α) (s' : ℕ → Set α) (V : ℕ → Set (α × α)) :
    m ((UniformSpace.interUnionBalls s' V)ᶜ) ≤
      ∑' n, m ((⋃ x ∈ s' n, UniformSpace.ball x (Prod.swap ⁻¹' V n))ᶜ) :=
  by
  rw [UniformSpace.interUnionBalls, Set.compl_iInter]
  apply measure_iUnion_le 

theorem measure_Inter_iUnion_uniform_balls (ε : ℝ≥0) (m : Measure α) (s' : ℕ → Set α)
    (V : ℕ → Set (α × α)) (δ : ℕ → ℝ≥0)
    (hδ1 : ∀ n, m ((⋃ x ∈ s' n, UniformSpace.ball x (Prod.swap ⁻¹' V n))ᶜ) ≤ δ n) (hδ2 : Summable δ)
    (hδ3 : ∑' n, δ n < ε) : m ((UniformSpace.interUnionBalls s' V)ᶜ) < ε :=
  by
  apply lt_of_le_of_lt (Inter_iUnion_uniform_balls_measure m s' V)
  have hδ3' : (∑' n, δ n : ℝ≥0∞) < (ε : ℝ≥0∞) :=
    by
    rw [← ENNReal.coe_tsum, ENNReal.coe_lt_coe]
    exacts [hδ3, hδ2]
  refine' lt_of_le_of_lt _ hδ3'
  exact ENNReal.tsum_le_tsum fun n => hδ1 n

-- TODO: explain that this is a pseudo-polish space.

theorem inner_regular_isCompact_is_closed_of_complete_countable' [UniformSpace α] [CompleteSpace α]
    [TopologicalSpace.SecondCountableTopology α] [(uniformity α).IsCountablyGenerated]
    [OpensMeasurableSpace α] (P : Measure α) [IsFiniteMeasure P] (ε : ℝ≥0) (hε : 0 < ε) :
    ∃ (K : _) (_ : IsCompact (closure K)), P (Kᶜ) < ε := by
  classical
  cases isEmpty_or_nonempty α
  case inl =>
    refine' ⟨∅, by rw [closure_empty]; exact isCompact_empty, _⟩
    rw [← Set.univ_eq_empty_iff.mpr] 
    · simpa only [compl_univ, measure_empty, ENNReal.coe_pos] using hε 
    · assumption 
  case inr =>
    rcases TopologicalSpace.exists_countable_dense α with ⟨s, hsc, hsd⟩
    obtain
    ⟨t : ℕ → Set (α × α), hto : ∀ i, t i ∈ (uniformity α).sets ∧ IsOpen (t i) ∧ SymmetricRel (t i),
      h_basis : (uniformity α).HasAntitoneBasis t⟩ :=
    (@uniformity_hasBasis_open_symmetric α _).exists_antitone_subbasis
    cases' (Set.countable_iff_exists_surjective (Dense.nonempty hsd)).1 hsc with f hf
    let f : ℕ → α → Set α := fun n x => UniformSpace.ball x (t n)
    obtain h_univ : ∀ n, (⋃ x ∈ s, f n x) = univ :=
      fun n => Dense.biUnion_uniformity_ball hsd (hto n).1
    have h3 : ∀ (n : ℕ) (ε : ℝ≥0∞) (_ : 0 < ε),
      ∃ (s' : Set α) (_ : s'.Finite) (_ : s' ⊆ s), P ((⋃ x ∈ s', f n x)ᶜ) < ε := by
      intro n ε hε
      simp_rw [compl_iUnion]
      let S : Set (Set α) := (fun t => (f n t)ᶜ) '' s
      have h_count : Countable S := by
        simp only [countable_coe_iff]
        exact hsc.image _
      have h_mea : ∀ s ∈ S, MeasurableSet s := by
        rintro u ⟨x, _, rfl⟩
        simp only [MeasurableSet.compl_iff, UniformSpace.ball]
        apply measurable_prod_mk_left
        apply IsOpen.measurableSet
        exact (hto n).2.1
      have h_inter_empty : ⋂₀ S = ∅ := by
        rw [← compl_compl ∅, compl_empty, ← h_univ n]
        simp only [sInter_image, compl_iUnion]
      rcases continuous_at_emptyset_inter P S h_count h_mea h_inter_empty hε
        with ⟨S', S'1, S'2, S'3⟩
      obtain hs' := Function.subset_image_fintype S'2 S'1
      rcases hs' with ⟨s', s'sub, s'fin, s'im⟩
      use s', s'fin, s'sub
      apply lt_of_eq_of_lt _ S'3
      simp only [← s'im, sInter_image]
    choose! s' s'fin _ s'bound using h3
    rcases NNReal.exists_seq_pos_summable_lt ε hε with ⟨δ, hδ1, hδ2, hδ3⟩
    have hδ1' : ∀ n, 0 < (δ n : ℝ≥0∞) := fun n => ENNReal.coe_pos.2 (hδ1 n)
    let u : ℕ → Finset α := fun n => (s'fin n (δ n) (hδ1' n)).toFinset
    let A := UniformSpace.interUnionBalls (fun n => (u n : Set α)) (fun n => t n)
    refine' ⟨A, UniformSpace.isCompact_closure_interUnionBalls h_basis.toHasBasis u, _⟩
    have hP : P (closure A)ᶜ ≤ P (Aᶜ) := by
      apply measure_mono 
      rw [← Set.compl_subset_compl, compl_compl, compl_compl]
      exact subset_closure 
    suffices h_meas_balls : P ((UniformSpace.interUnionBalls (fun n => ↑(u n)) fun n => t n)ᶜ) < ε
    · simp only [coe_toFinset] at hP h_meas_balls ⊢
      exact h_meas_balls 
    · refine' measure_Inter_iUnion_uniform_balls ε P (fun n => ↑(u n)) (fun n => t n) δ
        (fun n => _) hδ2 hδ3
      obtain h' := le_of_lt ((fun n => (s'bound n) (δ n) (hδ1' n)) n)
      have h1 : ∀ x, x ∈ s' n (δ n) ↔ x ∈ u n := by
        intro x
        simp only [Finite.mem_toFinset]
      obtain h'' : ∀ n, Prod.swap ⁻¹' t n = t n := fun n => SymmetricRel.eq (hto n).2.2
      simp_rw [Finset.mem_coe, ← h1, h'']
      exact h'

theorem exists_compact_measurable_set_measure_lt_of_complete_countable [UniformSpace α]
    [CompleteSpace α] [TopologicalSpace.SecondCountableTopology α]
    [(uniformity α).IsCountablyGenerated] [OpensMeasurableSpace α] (P : Measure α)
    [IsFiniteMeasure P] (ε : ℝ≥0) (hε : 0 < ε) : ∃ K, IsCompact K ∧ IsClosed K ∧ P (Kᶜ) < ε :=
  by
  obtain ⟨K, hK, hPK⟩ := inner_regular_isCompact_is_closed_of_complete_countable' P ε hε
  refine' ⟨closure K, hK, isClosed_closure, (measure_mono _).trans_lt hPK⟩
  exact compl_subset_compl.mpr subset_closure

theorem innerRegular_isCompact_isClosed_of_complete_countable [UniformSpace α] [CompleteSpace α]
    [TopologicalSpace.SecondCountableTopology α] [(uniformity α).IsCountablyGenerated]
    [OpensMeasurableSpace α] (P : Measure α) [IsFiniteMeasure P] :
    P.InnerRegular (fun s => IsCompact s ∧ IsClosed s) IsClosed :=
  innerRegular_isCompact_isClosed_of_univ' P
    (exists_compact_measurable_set_measure_lt_of_complete_countable P)

theorem innerRegular_isCompact_isClosed_isOpen_of_complete_countable [PseudoEMetricSpace α]
    [CompleteSpace α] [TopologicalSpace.SecondCountableTopology α] [OpensMeasurableSpace α]
    (P : Measure α) [IsFiniteMeasure P] :
    P.InnerRegular (fun s => IsCompact s ∧ IsClosed s) IsOpen :=
  (innerRegular_isCompact_isClosed_of_complete_countable P).trans
    (Measure.InnerRegular.of_pseudoEMetricSpace P)

/-- TODO: this is the useful result for the Kolmogorov extension theorem. -/
theorem innerRegular_isCompact_isClosed_measurableSet_of_complete_countable [PseudoEMetricSpace α]
    [CompleteSpace α] [TopologicalSpace.SecondCountableTopology α] [BorelSpace α] (P : Measure α)
    [IsFiniteMeasure P] : P.InnerRegular (fun s => IsCompact s ∧ IsClosed s) MeasurableSet :=
  by
  suffices P.InnerRegular (fun s => IsCompact s ∧ IsClosed s) fun s => MeasurableSet s ∧ P s ≠ ∞ by
    convert this
    -- ext1 s
    simp only [eq_iff_iff, iff_self_and]
    exact fun _ => measure_ne_top P _
  refine' Measure.InnerRegular.measurableSet_of_open _ ⟨isCompact_empty, isClosed_empty⟩ _
  · exact innerRegular_isCompact_isClosed_isOpen_of_complete_countable P
  · rintro s t ⟨hs_compact, hs_closed⟩ ht_open
    rw [diff_eq]
    exact
      ⟨hs_compact.inter_right ht_open.isClosed_compl,
        hs_closed.inter (isClosed_compl_iff.mpr ht_open)⟩

-- now unused. But useful in general?
instance weaklyRegular_of_polishSpace [TopologicalSpace α] [PolishSpace α] [BorelSpace α]
    (μ : Measure α) [IsFiniteMeasure μ] : μ.WeaklyRegular :=
  letI := upgradePolishSpace α
  MeasureTheory.Measure.WeaklyRegular.of_pseudoEMetricSpace_of_isFiniteMeasure μ

/-- On a Polish space, any finite measure is regular with respect to compact and closed sets. -/
theorem PolishSpace.innerRegular_isCompact_measurableSet [TopologicalSpace α] [PolishSpace α]
    [BorelSpace α] (μ : Measure α) [IsFiniteMeasure μ] :
    μ.InnerRegular (fun s => IsCompact s ∧ IsClosed s) MeasurableSet := by
  letI := upgradePolishSpace α
  refine innerRegular_isCompact_isClosed_measurableSet_of_complete_countable μ

end MeasureTheory

