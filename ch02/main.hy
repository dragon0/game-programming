(import pygame)
(import [pygame.locals [*]])

(import [game-math [Vector2]])
(import [component [BGSpriteComponent]])
(import [actor [Actor DEAD]])
(import [ship [Ship]])


(setv width 1024)
(setv height 768)

(defclass Game [object]
  (defn --init-- [self]
    (setv self.surface None)
    (setv self.clock None)
    (setv self.is-running True)
    (setv self.textures {})
    (setv self.actors [])
    (setv self.pending-actors [])
    (setv self.sprites [])
    (setv self.updating-actors False)

    ; game-specific
    (setv self.ship None); player's ship
    )

  (defn initialize [self]
    (pygame.init)
    (setv display (, width height))
    (setv self.surface (pygame.display.set-mode display DOUBLEBUF))
    (setv self.clock (pygame.time.Clock))
    (setv self.font (pygame.font.SysFont None 30))

    (self.load-data)

    True)

  (defn run-loop [self]
    (while self.is-running
      (self.process-input)
      (self.update-game)
      (self.generate-output)))

  (defn shutdown [self]
    (self.unload-data))

  (defn process-input [self]
    (for [event (pygame.event.get)]
      (if (= event.type pygame.QUIT)
        (setv self.is-running False)))

    (setv state (pygame.key.get-pressed))
    (if (get state K_ESCAPE)
      (setv self.is-running False))

    (self.ship.process-keyboard state))

  (defn update-game [self]
    ; limit fps
    (setv delta-time (self.clock.tick 60))
    ; clamp maximum delta time
    (if (> delta-time 0.05)
      (setv delta-time 0.05))

    (setv self.updating-actors True)
    (for [actor self.actors] (actor.update delta-time))
    (setv self.updating-actors False)

    (self.actors.extend self.pending-actors)
    (self.pending-actors.clear)

    (setv self.actors (lfor actor self.actors
                        :if (!= (actor.get-state) DEAD)
                        actor))
    )

  (defn generate-output [self]
    ; clear screen
    (self.surface.fill (, 0 0 255))
    (for [sprite self.sprites]
      (sprite.draw self.surface))
    ; flip buffers
    (pygame.display.flip))

  (defn load-data [self]
    ; create player's ship
    (setv self.ship (Ship self))
    (self.ship.set-position (Vector2 100 384))
    (self.ship.set-scale 1.5)

    ; create actor for the background
    (setv temp (Actor self))
    (temp.set-position (Vector2 512 384))

    ; create the "far back" background
    (setv bg (BGSpriteComponent temp))
    (bg.set-screen-size (Vector2 1024 768))
    (bg.set-bg-textures
      [(self.get-texture "Assets/Farback01.png")
       (self.get-texture "Assets/Farback02.png")])
    (bg.set-scroll-speed -100)

    ; create the closer background
    (setv bg (BGSpriteComponent temp 50))
    (bg.set-screen-size (Vector2 1024 768))
    (bg.set-bg-textures
      [(self.get-texture "Assets/Stars.png")
       (self.get-texture "Assets/Stars.png")])
    (bg.set-scroll-speed -200)
    )

  (defn unload-data [self])

  (defn get-texture [self file-name]
    (if (in file-name self.textures)
      (get self.textures file-name)
      (do
        (setv surf (pygame.image.load file-name))
        (setv surf (surf.convert-alpha))
        (assoc self.textures file-name surf)
        surf)))

  (defn add-actor [self actor]
    (if self.updating-actors
      (self.pending-actors.append actor)
      (self.actors.append actor)))

  (defn remove-actor [self actor]
    (if (in actor self.pending-actors) (self.pending-actors.remove actor))
    (if (in actor self.actors) (self.actors.remove actor))
    )

  (defn add-sprite [self sprite]
    (setv draw-order (sprite.get-draw-order))
    (setv index 0)
    (for [(, index spr) (enumerate self.sprites)]
      (if (< draw-order (spr.get-draw-order) (break))))
    (self.sprites.insert index sprite)
    )

  (defn remove-sprite [self sprite]
    (if (in sprite self.sprites) (self.sprites.remove sprite))
    )
  )

(defmain [&rest args]
  (setv game (Game))
  (setv success (game.initialize))
  (if success (game.run-loop))
  (game.shutdown))
