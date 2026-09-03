## Code Quality

### Stata

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (silence_master.do, line 19)
  → global userpath "/Users/yihong/Desktop/Replication Package 20241100" //Yihong

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure 3.do, line 10)
  → keep if topic == "rename_schools" | topic == "affirmative_action" | topic == "dst" | topic == "death_penalty" | topic == "immunizations"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure 3.do, line 40)
  → keep if _merge == 3

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure 3.do, line 43)
  → keep if _merge == 3

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure E11.do, line 9)
  → drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure E11.do, line 23)
  → drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Figure E11.do, line 33)
  → drop if topic == "free_speech" | topic == "homeless_camps" | topic == "peoples_park" | topic == "immunizations"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table 3.do, line 12)
  → keep if treat == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table 3.do, line 21)
  → keep if treat == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table C4.do, line 4)
  → keep if attr == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table D14.do, line 17)
  → drop if frac_`var'_s_a > 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table D15.do, line 139)
  → drop if frac_`var'_s_a > 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table E23.do, line 7)
  → drop if year < 1974

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table E23.do, line 8)
  → keep if misperception !=. & n_silent!=0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table E23.do, line 79)
  → drop if year < 1974

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (Table E23.do, line 80)
  → keep if misperception !=. & n_silent!=0

