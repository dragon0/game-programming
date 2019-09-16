(import [math [degrees]])
(import pygame)
(import [game-math [Vector2]])

(defclass Component []
  (defn --init-- [self owner &optional [update-order 100]]
    (setv self.owner owner)
    (setv self.update-order update-order)
    (owner.add-component self)
    )
  (defn get-update-order [self] self.update-order)

  (defn update [self delta-time]); virtual
  )

(defclass SpriteComponent [Component]
  (defn --init-- [self owner &optional [draw-order 100]]
    (Component.--init-- self owner)
    (setv self.surf None)
    (setv self.draw-order draw-order)
    (setv self.tex-height 0)
    (setv self.tex-width 0)
    (setv game (owner.get-game))
    (game.add-sprite self)
    )

  (defn draw [self surface]
    (if self.surf
      (do
        (setv surf
          (pygame.transform.rotozoom
            self.surf
            (degrees (self.owner.get-rotation))
            (self.owner.get-scale)))
        (setv pos
          (,
            (int (- (. (self.owner.get-position) x) (/ self.tex-width 2)))
            (int (- (. (self.owner.get-position) y) (/ self.tex-height 2)))
            ))
        (surface.blit surf pos)
        )))

  (defn set-texture [self surf]
    (setv self.surf surf)
    (setv self.tex-width (surf.get-width))
    (setv self.tex-height (surf.get-height))
    )

  (defn get-draw-order [self] self.draw-order)
  (defn get-tex-height [self] self.tex-height)
  (defn get-tex-width [self] self.tex-width)
  )

(defclass AnimSpriteComponent [SpriteComponent]
  (defn --init-- [self owner &optional [draw-order 100]]
    (SpriteComponent.--init-- self owner draw-order)
    (setv self.anim-textures [])
    (setv self.curr-frame 0)
    (setv self.anim-fps 24)
    )

  (defn update [self delta-time]
    (SpriteComponent.update self delta-time)
    (if self.anim-textures
      (do
        (+= self.curr-frame (* self.anim-fps delta-time))
        (while (>= self.curr-frame (len self.anim-textures))
          (-= self.curr-frame (len self.anim-textures)))
        (self.set-texture (get self.anim-textures (int self.curr-frame)))
        ))
    )

  (defn set-anim-textures [self textures]
    (setv self.anim-textures textures)
    (if textures
      (do
        (setv self.curr-frame 0)
        (self.set-texture (get textures 0)))))

  (defn get-anim-fps [self] self.anim-fps)
  (defn set-anim-fps [self fps] (setv self.anim-fps fps))
  )

(defclass BGSpriteComponent [SpriteComponent]
  (defclass BGTexture []
    (defn --init-- [self texture offset]
      (setv self.texture texture)
      (setv self.offset offset)))

  (defn --init-- [self owner &optional [draw-order 10]]
    (SpriteComponent.--init-- self owner draw-order)
    (setv self.bg-textures [])
    (setv self.screen-size (Vector2))
    (setv self.scroll-speed 0)
    )

  (defn update [self delta-time]
    (for [bg self.bg-textures]
      (+= bg.offset.x (* self.scroll-speed delta-time))
      ; if this is completely off the screen, reset to right of last texture
      (if (< bg.offset.x (- self.screen-size.x))
        (setv bg.offset.x (-
                            (*
                              (- (len self.bg-textures) 1)
                              self.screen-size.x)
                            1))
        )))

  (defn draw [self surface]
    (for [bg self.bg-textures]
      (setv pos
        (,
          (int (+ (- (. (self.owner.get-position) x) (/ self.screen-size.x 2)) bg.offset.x))
          (int (+ (- (. (self.owner.get-position) y) (/ self.screen-size.y 2)) bg.offset.y))
          ))
      (surface.blit bg.texture pos)
      ))

  (defn set-bg-textures [self textures]
    (setv count 0)
    (for [tex textures]
      (setv temp (BGSpriteComponent.BGTexture
                   tex (Vector2 (* count self.screen-size.x) 0)))
      (self.bg-textures.append temp)
      (+= count 1)
      )
    )

  (defn set-screen-size [self size] (setv self.screen-size size))
  (defn set-scroll-speed [self speed] (setv self.scroll-speed speed))
  (defn get-scroll-speed [self] self.scroll-speed)
  )
