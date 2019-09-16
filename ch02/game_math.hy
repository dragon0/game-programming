(import [math [*]])

(setv two-pi (* pi 2))
(setv pi-over-two (/ pi 2))
(setv inf (float "inf"))
(setv neg-inf (- inf))

(defn near-zero [val &optional [epsilon 0.001]] (<= (abs val) epsilon))
(defn clamp [val lower upper] (min upper (max lower value)))
(defn lerp [a b f] (+ a (* f (- b a))))

(defclass Vector2 [object]
  (defn --init-- [self &optional [x 0.0] [y 0.0]]
    (do
    (setv self.x x)
    (setv self.y y)))

  (defn --str-- [self]
    (.format "Vector2({self.x}, {self.y})" :self self))

  (defn --add-- [a b]
    (Vector2 (+ a.x b.x) (+ a.y b.y)))
  (setv --radd-- --add--)

  (defn --sub-- [a b]
    (Vector2 (- a.x b.x) (- a.y b.y)))
  (defn --rsub-- [a b]
    (- b a))

  (defn --mul-- [a b]
    (if isinstance(b Vector2)
      (Vector2 (* a.x b.x) (* a.y b.y))
      (Vector2 (* a.x b) (* a.y b))))
  (defn --rmul [a b] (* b a))

  (defn length-sq [self] (+ (* self.x self.x) (* self.y self.y)))
  (defn length [self] (sqrt (self.length-sq)))

  (defn normalize [self]
    (setv length (self.length))
    (/= self.x length)
    (/= self.y length)
    None)

  (defn dot [a b]
    (+ (* a.x b.x) (* a.y b.y)))

  (defn reflect [v n]
    (- v (* 2.0 (v.dot n) n)))
  )
