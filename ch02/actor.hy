(import [game-math [Vector2]])

(setv ACTIVE "ACTIVE")
(setv PAUSED "PAUSED")
(setv DEAD   "DEAD")

(defclass Actor []
  (defn --init-- [self game]
    (setv self.state ACTIVE)
    (setv self.position (Vector2))
    (setv self.scale 1.0)
    (setv self.rotation 0.0)
    (setv self.components [])
    (setv self.game game)
    (game.add-actor self)
    )

  (defn update [self delta-time]
    (if (= self.state ACTIVE)
      (do
        (self.update-components delta-time)
        (self.update-actor delta-time))))

  (defn update-components [self delta-time]
    (for [component self.components]
      (component.update delta-time)))

  (defn update-actor [self delta-time]); virtual

  (defn get-position [self] self.position)
  (defn set-position [self pos] (setv self.position pos))
  (defn get-scale [self] self.scale)
  (defn set-scale [self scale] (setv self.scale scale))
  (defn get-rotation [self] self.rotation)
  (defn set-rotation [self rotation] (setv self.rotation rotation))
  (defn get-state [self] self.state)
  (defn set-state [self state] (setv self.state state))
  (defn get-game [self] self.game)

  (defn add-component [self component]
    (setv update-order (component.get-update-order))
    (setv index 0)
    (for [(, index com) (enumerate self.components)]
      (if (< update-order (com.get-update-order) (break))))
    (self.components.insert index component)
    )

  (defn remove-component [self component]
    (if (in component self.components) (self.components.remove component))
    )
  )

