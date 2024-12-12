;; Day11.el: My solution in Emacs Lisp!

(defun main (input-file)
  "Main function of our script!"

  ;; SETUP! ;;

  ;; Read list of pebbles from the input file. It expects only one line of input.
  (setq pebbles-list (with-temp-buffer
                       (insert-file-contents input-file)
                       (mapcar (lambda (x) (string-to-number x))
                               (split-string (buffer-string)))))

  ;; Total blinks!
  (defconst num-blinks-1 25)
  (defconst num-blinks-2 75)

  ;; Apply the algorithm the number of times the problem asks to each pebble in
  ;; the list, and add all those results together.

  ;; PART ONE! ;;
  (setq twenty-five-blinks 0)

  (dolist (x pebbles-list)
    (setq twenty-five-blinks (+ (apply-plutonian-blink x num-blinks-1)
                                twenty-five-blinks)))
  (message "PART ONE: %s" twenty-five-blinks)

  ;; PART TWO! ;;
  (setq seventy-five-blinks 0)

  (dolist (x pebbles-list)
    (setq seventy-five-blinks (+ (apply-plutonian-blink x num-blinks-2)
                                 seventy-five-blinks)))
  (message "PART TWO: %s" seventy-five-blinks))


;; ***************** ;;
;; HELPER FUNCTIONS! ;;
;; ***************** ;;

(setq pluto-dp-hash (make-hash-table :test 'equal))

(defun apply-plutonian-blink (pebble blinks-left)
  "Apply the algorithm of the Plutonian Pebbles spacetime manipulation:
- If engraved with number 0, then it becomes engraved with number 1.
- If engraved with an even number of digits, split it into two halves.
- If none of the above, then multiply its number by 2024."

  (let* ((pluto-dp-key (pluto-state-key pebble blinks-left))
         (result (gethash pluto-dp-key pluto-dp-hash)))

    ;; If result is nil, then that means we haven't found this particular pebble
    ;; with this specific amount of remaining steps, so we have to calculate its
    ;; answer. Then, store it into our dp hash.

    (when (not result)
      (setq result (cond
                    ((= 0 blinks-left) 1)

                    ((= 0 pebble) (apply-plutonian-blink 1 (- blinks-left 1)))

                    ((has-even-digits pebble)
                     (let* ((peb-str (number-to-string pebble))
                            (full-len (length peb-str))
                            (half-len (/ full-len 2))
                            (left-peb (string-to-number (substring peb-str 0 half-len)))
                            (right-peb (string-to-number (substring peb-str half-len full-len))))

                       ;; This stone got split in halves, so we now have to calculate
                       ;; the algorithm for each of the halves independently.
                       (+ (apply-plutonian-blink left-peb (- blinks-left 1))
                          (apply-plutonian-blink right-peb (- blinks-left 1)))))

                    (t (apply-plutonian-blink (* pebble 2024) (- blinks-left 1)))))

      (puthash pluto-dp-key result pluto-dp-hash))
    result))

(defun has-even-digits (number)
  "Calculates and returns the total number of digits in the given integer."
  (= 0 (% (length (number-to-string number)) 2)))


(defun pluto-state-key (pebble-val blink-num)
  "To store the intermediate results of the Plutonian Blink Algorithm, we need to
store each final state we come by somewhere. On Python and Ruby, we could use the
tuple as key, but Elisp doesn't have this functionality. So, we use this auxiliary
function to generate a unique string for the given state that we can use as the
key to store it and retrieve it from the Hash Map."
  (format "%d:%d" pebble-val blink-num))


;; ********** ;;
;; CALL MAIN! ;;
;; ********** ;;

(main (nth 3 command-line-args))


;; ************************************************* ;;
;; EXTRA: NAIVE ALGORITHM! STOPS WORKING AROUND LV40 ;;
;; ************************************************* ;;

(defun apply-plutonian-blink-naive (pebbles-list)
  "Apply the algorithm of the Plutonian Pebbles spacetime manipulation:
- If engraved with number 0, then it becomes engraved with number 1.
- If engraved with an even number of digits, split it into two halves.
- If none of the above, then multiply its number by 2024."
  (flatten-tree (mapcar (lambda (x) (cond ((= x 0) 1)
                                          ((= (% (num-digits x) 2) 0) (split-num-halves x))
                                          (t (* x 2024))))
                        pebbles-list)))


(defun split-num-halves (number)
  "Split the given number into two containing each one half of its digits."
  (let* ((num-str (number-to-string number))
         (str-size (length num-str))
         (half-size (/ str-size 2)))

    ;; Make a list of substrings with each half and map them to numbers.
    (mapcar (lambda (x) (string-to-number x))
            (list (substring num-str 0 half-size) (substring num-str half-size str-size)))))
