;*=====================================================================*/
;*    .../diffusion/article/flt/fst-artifact/scripts/bmem2csv.scm      */
;*    -------------------------------------------------------------    */
;*    Author      :  manuel serrano                                    */
;*    Creation    :  Fri Nov  1 19:53:56 2024                          */
;*    Last change :  Tue Jul 15 13:46:18 2025 (serrano)                */
;*    Copyright   :  2024-25 manuel serrano                            */
;*    -------------------------------------------------------------    */
;*    Convert bmem profiles into a CSV file.                           */
;*=====================================================================*/

;*---------------------------------------------------------------------*/
;*    The module                                                       */
;*---------------------------------------------------------------------*/
(module foo
   (main main))

;*---------------------------------------------------------------------*/
;*    configuration                                                    */
;*---------------------------------------------------------------------*/
(define *base-color* "red")
(define *offset-tables*
   `#(- #(0)
	#(0 0)
	#(,(- (/ 1 6)) ,(/ 1 6))
	#(,(- (/ 1 6)) 0 ,(/ 1 6))
	#(,(- (/ 2 7)) ,(- (/ 1 8)) ,(/ 1 8) ,(/ 2 7))
	#(,(- (/ 2 6)) ,(- (/ 1 6)) 0 ,(/ 1 6) ,(/ 2 6))
	#(,(- (/ 3 6)) ,(- (/ 2 6)) ,(- (/ 1 6)) 0 ,(/ 1 6) ,(/ 2 6) ,(/ 3 6))))
(define *separator* -1)
(define *aliases* '())

(define *colors*
   '#("#3264c8" "#fa9600" "#d83812" "#109318"
      "#93ade2" "#edd20b" "#00a0bf" "#72bf00"
      "#969996" "#4b30ed"))

(define *ratio* "6,2")

(define *key* "under nobox")

;*---------------------------------------------------------------------*/
;*    *template* ...                                                   */
;*---------------------------------------------------------------------*/
(define *template* "set terminal pdf font 'Verdana,12' size @RATIO@

#set title 'Memory allocation'
set tmargin 0.2
set ylabel 'relative allocation' offset 0,0

set auto x

set style data histogram
set style histogram gap 1
set errorbars lc rgb '#444444'
set xtics rotate by 45 right

set xtics font 'Verdana,8'
set ytics font 'Verdana,10'

set boxwidth 0.9
set style fill solid

set style line 1 linecolor rgb '@COLOR0@' linetype 1 linewidth 1
set style line 2 linecolor rgb '@COLOR1@' linetype 1 linewidth 1
set style line 3 linecolor rgb '@COLOR2@' linetype 1 linewidth 1
set style line 4 linecolor rgb '@COLOR3@' linetype 1 linewidth 1
set style line 5 linecolor rgb '@COLOR4@' linetype 1 linewidth 1
set style line 6 linecolor rgb '@COLOR5@' linetype 1 linewidth 1
set style line 7 linecolor rgb '@COLOR6@' linetype 1 linewidth 1
set style line 8 linecolor rgb '@COLOR7@' linetype 1 linewidth 1
set style line 9 linecolor rgb '@COLOR8@' linetype 1 linewidth 1
set style line 10 linecolor rgb '@COLOR9@' linetype 1 linewidth 1
set style line 100 linecolor rgb '#000000' linetype 1 linewidth 1
set style line 1000 linecolor rgb '#555555 linewidth 20

set grid ytics
set xtics scale 0
set datafile separator ','

set yrange [0:*]

set lmargin 6
set rmargin 1
set bmargin 3")

;*---------------------------------------------------------------------*/
;*    main ...                                                         */
;*---------------------------------------------------------------------*/
(define (main argv)
   (multiple-value-bind (dirs compilers)
      (split-arguments (cddr argv))
      (let ((dirs (filter directory? dirs))
	    (output (cadr argv)))
	 ;; read the file in the first directory to get the stat list
	 (when (pair? dirs)
	    (let ((files (if (pair? compilers)
			     (map (lambda (c) (string-append c ".bmem")) compilers)
			     (sort string<=?
				(filter (lambda (s)
					   (not (pregexp-match ".*~$" s)))
				   (directory->list (car dirs)))))))
	       ;; csv
	       (printf "# ~( )\n" files)
	       (for-each (lambda (d)
			    (let ((data (append-map (lambda (f)
						       (let ((path (make-file-name d f)))
							  (if (file-exists? path)
							      (list (car (bmem->csv path)))
							      '(0))))
					   files)))
			       (printf "~a, ~(, )\n" (basename d)
				  (map (lambda (d) (/ d (car data)))
				     (cdr data)))))
		  dirs)
	       (newline)
	       ;; plot
	       (bmem->plot output files))))))

;*---------------------------------------------------------------------*/
;*    split-arguments ...                                              */
;*---------------------------------------------------------------------*/
(define (split-arguments argv)
   (let loop ((dirs '())
	      (argv argv))
      (cond
	 ((null? argv)
	  (values (reverse! dirs) '()))
	 ((string=? (car argv) "-:-")
	  (values (reverse! dirs) (cdr argv)))
	 ((string=? (car argv) "--separator")
	  (set! *separator* (string->integer (cadr argv)))
	  (loop dirs (cddr argv)))
	 ((string=? (car argv) "--alias")
	  (set! *aliases* (cons (cons (cadr argv) (caddr argv)) *aliases*))
	  (loop dirs (cdddr argv)))
	 ((string=? (car argv) "--colors")
	  (vector-copy! *colors* 0 (list->vector (string-split (cadr argv) " ,")))
	  (loop dirs (cddr argv)))
	 ((string=? (car argv) "--ratio")
	  (set! *ratio* (cadr argv))
	  (loop dirs (cddr argv)))
	 ((string=? (car argv) "--key")
	  (set! *key* (cadr argv))
	  (loop dirs (cddr argv)))
 	 (else
	  (loop (cons (car argv) dirs) (cdr argv))))))

;*---------------------------------------------------------------------*/
;*    get ...                                                          */
;*---------------------------------------------------------------------*/
(define (get kwd data)
   (let ((c (assq kwd data)))
      (if (not (pair? c))
	  (error "bmem2csv" "Cannot find" kwd)
	  (cdr c))))

;*---------------------------------------------------------------------*/
;*    bmem->csv ...                                                    */
;*---------------------------------------------------------------------*/
(define (bmem->csv file)
   (call-with-input-file file
      (lambda (p)
	 (match-case (read p)
	    ((monitor ?m . ?data)
	     (let ((alloc (get 'alloc data))
		   (types (get 'types data)))
		(let ((kbsize (car (get 'kbsize alloc)))
		      (types (get 'types types)))
		   (unless (>fx kbsize 0)
		      (error file "wrong alloc size" kbsize))
		   (let ((real (assq 'real types)))
		      (if (pair? real)
			  (let ((kbsizer (get kbsize: (cdr real))))
			     (list kbsize (car kbsizer)))
			  (list kbsize 0))))))
	    (else
	     (error "bmem2csv" "wrong file format" file))))))

;*---------------------------------------------------------------------*/
;*    nice ...                                                         */
;*---------------------------------------------------------------------*/
(define (nice str)
   (let ((patterns '(("bigloo_fltnz" "Scheme self tagging (2 tags)")
		     ("bigloo_fltlb" "Scheme self tagging (2 tags, mantissa low-bits)")
		     ("bigloo_nan" "Scheme nan tagging")
		     ("bigloo_flt1" "Scheme self tagging (1 tag)")
		     ("bigloo_flt" "Scheme self tagging (3 tags)")
		     ("bigloo" ""))))
      (let loop ((patterns patterns)
		 (str (prefix str)))
	 (if (null? patterns)
	     str
	     (loop (cdr patterns) (pregexp-replace (caar patterns) str (cadar patterns)))))))

;*---------------------------------------------------------------------*/
;*    bmem->plot ...                                                   */
;*---------------------------------------------------------------------*/
(define (bmem->plot output compilers)
   
   (define (draw sep)
      (fprintf (current-error-port) "set arrow 1 from graph 0, first 1 to graph 1, first 1 nohead lc '~a' lw 2 dt '---' front\n" *base-color*)
      (fprintf (current-error-port) "set label 1 '~a' font 'Verdana,10' at 20,1 offset -0.5,0.5 tc 'red'\n\n" (nice (car compilers)) *base-color*)
      
      (when sep
	 (fprintf (current-error-port) "set arrow from ~a,graph 0 to ~a,graph 1 nohead ls 1000 dashtype 2 front\n\n"
	    (- *separator* 0.5) (- *separator* 0.5)))

      (fprintf (current-error-port) "plot \\\n~(,\\\n),\\\n~(,\\\n)\n"
	 (map (lambda (comp idx)
		 (format "  '~a.csv' u ~a:xtic(1) title '~a' ls ~a"
		    output idx (nice comp) idx))
	    (cdr compilers) (iota (-fx (length compilers) 1) 2))
	 (let ((table (vector-ref *offset-tables* (length compilers))))
	    (map (lambda (comp idx)
		    (format "  '~a.csv' u ($0+~a):(round(($~a+0.1)*10.0) / 10.0):(sprintf(\"%3.2f\",$~a)) with labels font 'Verdana,6' rotate by 90 notitle"
		       output (vector-ref table (-fx idx 2)) idx idx))
	       (cdr compilers) (iota (-fx (length compilers) 1) 2)))))

   ;; color patching
   (let loop ((i (-fx (vector-length *colors*) 1)))
      (when (>= i 0)
	 (set! *template*
	    (pregexp-replace* (format "@COLOR~a@" i)
	       *template* (vector-ref *colors* i)))
	 (loop (-fx i 1))))
      
   (set! *template*
      (pregexp-replace* "@RATIO@" *template* *ratio*))
      
   (when (>fx *separator* 0)
      (fprint (current-error-port) "set output '/dev/null'\nset terminal dumb\n")
      (draw #f)
      (fprint (current-error-port) "\nreset\n"))

   (fprintf (current-error-port) "set output '~a.pdf'\n" output)
   (fprint (current-error-port) *template*)
   
   (fprint (current-error-port) "set key " *key*)

   (draw (>fx *separator* 0)))

;*---------------------------------------------------------------------*/
;*    *offset-tables*                                                  */
;*---------------------------------------------------------------------*/

