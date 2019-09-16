(import [pygame.locals [*]])
(import [actor [Actor]])
(import [component [AnimSpriteComponent]])

(defclass Ship [Actor]
  (defn --init-- [self game]
    (Actor.--init-- self game)
    (setv self.right-speed 0.0)
    (setv self.down-speed 0.0)
    (setv asc (AnimSpriteComponent self))
    (asc.set-anim-textures
      [
       (game.get-texture "Assets/Ship01.png")
       (game.get-texture "Assets/Ship02.png")
       (game.get-texture "Assets/Ship03.png")
       (game.get-texture "Assets/Ship04.png")
       ])
    )

  (defn update-actor [self delta-time]
    (Actor.update-actor self delta-time)
    (setv pos (self.get-position))
    (+= pos.x (* self.right-speed delta-time))
    (+= pos.y (* self.down-speed delta-time))
    (if (< pos.x 25) (setv pos.x 25))
    (if (> pos.x 500) (setv pos.x 500))
    (if (< pos.y 25) (setv pos.y 25))
    (if (> pos.y 743) (setv pos.y 743))
    (self.set-position pos)
    )

  (defn process-keyboard [self state]
    (setv self.right-speed 0.0)
    (setv self.down-speed 0.0)

    (if (get state K_d) (+= self.right-speed 250))
    (if (get state K_a) (-= self.right-speed 250))
    (if (get state K_s) (+= self.down-speed 300))
    (if (get state K_w) (-= self.down-speed 300))
    )

  (defn get-right-speed [self] self.right-speed)

  (defn get-down-speed [self] self.down-speed)

  )
