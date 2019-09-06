(import pygame)
(import [pygame.locals [*]])

(defclass Vector2 [object]
  (defn --init-- [self x y]
    (do
    (setv self.x x)
    (setv self.y y)))

  (defn --str-- [self]
    (.format "Vector2({self.x}, {self.y})" :self self))
  )

(setv thickness 15)
(setv paddleH 100.0)
(setv width 1024)
(setv height 768)

(defclass Game [object]
  (defn --init-- [self]
    (setv self.surface None)
    (setv self.clock None)
    (setv self.is-running True)
    (setv self.paddle-dir 0)
    (setv self.paddle-pos (Vector2 10.0 (/ height 2.0)))
    (setv self.ball-pos (Vector2 (/ width 2.0) (/ height 2.0)))
    (setv self.ball-vel (Vector2 200 235)))

  (defn initialize [self]
    (pygame.init)
    (setv display (, width height))
    (setv self.surface (pygame.display.set-mode display DOUBLEBUF))
    (setv self.clock (pygame.time.Clock))
    (setv self.font (pygame.font.SysFont None 30))
    True)

  (defn run-loop [self]
    (while self.is-running
      (self.process-input)
      (self.update-game)
      (self.generate-output)))

  (defn shutdown [self])

  (defn process-input [self]
    (for [event (pygame.event.get)]
      (if (= event.type pygame.QUIT)
        (setv self.is-running False)))

    (setv state (pygame.key.get-pressed))
    (if (get state K_ESCAPE)
      (setv self.is-running False))

    (setv self.paddle-dir 0)
    (if (get state K_w)
      (-= self.paddle-dir 1))
    (if (get state K_s)
      (+= self.paddle-dir 1)))

  (defn update-game [self]
    ; limit fps
    (setv delta-time (self.clock.tick 60))
    ; clamp maximum delta time
    (if (> delta-time 0.05)
      (setv delta-time 0.05))

    ; update paddle position based on direction
    (if (!= self.paddle-dir 0)
      (setv self.paddle-pos.y (+ self.paddle-pos.y
                                (* self.paddle-dir 300 delta-time)))
      ; make sure paddle doesn't move off screen
      (cond
        [(< self.paddle-pos.y (+ (/ paddleH 2.0) thickness))
         (setv self.paddle-pos.y (+ (/ paddleH 2.0) thickness))]
        [(> self.paddle-pos.y (- height (/ paddleH 2.0) thickness))
         (setv self.paddle-pos.y (- height (/ paddleH 2.0) thickness))])
      )

    ; update ball position
    (+= self.ball-pos.x (* self.ball-vel.x delta-time))
    (+= self.ball-pos.y (* self.ball-vel.y delta-time))

    ; bounce if needed
    (setv diff (abs (- self.paddle-pos.y self.ball-pos.y)))
    (cond
      ; did we intersect with the paddle?
      [(and 
         ; our y-difference is small enough
         (<= diff (/ paddleH 2.0))
         ; we are in the correct x position
         (<= self.ball-pos.x 25)
         (>= self.ball-pos.x 20)
         ; the ball is moving left
         (< self.ball-vel.x 0))
       (*= self.ball-vel.x -1)]
      ; did the ball go off the screen?
      [(<= self.ball-pos.x 0)
       (do
         (setv self.ball-pos (Vector2 (/ width 2.0) (/ height 2.0)))
         (setv self.ball-vel (Vector2 200 235)))]
      ; did the ball collide with the right wall?
      [(and
         (>= self.ball-pos.x (- width thickness))
         (> self.ball-vel.x 0))
       (*= self.ball-vel.x -1)]
      )

    (cond
      ; did the ball collide with the top wall?
      [(and
         (<= self.ball-pos.y thickness)
         (< self.ball-vel.y 0))
       (*= self.ball-vel.y -1)]
      ; did the ball collide with the bottom wall?
      [(and
         (>= self.ball-pos.y (- height thickness))
         (> self.ball-vel.y 0))
       (*= self.ball-vel.y -1)])


    )

  (defn generate-output [self]
    (self.surface.fill (, 0 0 255))
    (setv color (, 255 255 255))
    ; draw top wall
    (setv rect (pygame.Rect 0 0 width thickness))
    (pygame.draw.rect self.surface color rect)
    ; draw bottom wall
    (setv rect (pygame.Rect 0 (- height thickness) width thickness))
    (pygame.draw.rect self.surface color rect)
    ; draw right wall
    (setv rect (pygame.Rect (- width thickness) 0 thickness height))
    (pygame.draw.rect self.surface color rect)
    ; draw paddle
    (setv rect (pygame.Rect (int self.paddle-pos.x)
                            (int (- self.paddle-pos.y (/ paddleH 2)))
                            thickness
                            (int paddleH)))
    (pygame.draw.rect self.surface color rect)
    ; draw ball
    (setv rect (pygame.Rect (int (- self.ball-pos.x (/ thickness 2)))
                            (int (- self.ball-pos.y (/ thickness 2)))
                            thickness
                            thickness))
    (pygame.draw.rect self.surface color rect)
    ; draw debug info
    ;(print self.paddle-dir self.paddle-pos self.ball-pos self.ball-vel)
    (setv pdsurf (self.font.render (+ "paddle dir " (str self.paddle-dir)) False color))
    (setv ppsurf (self.font.render (+ "paddle pos " (str self.paddle-pos)) False color))
    (setv bpsurf (self.font.render (+ "ball pos " (str self.ball-pos)) False color))
    (setv bvsurf (self.font.render (+ "ball vel " (str self.ball-vel)) False color))
    (setv bvsurf-rect (bvsurf.get-rect
                        :bottomright (, (- width thickness) (- height thickness))))
    (setv bpsurf-rect (bpsurf.get-rect
                        :bottomright (, (- width thickness)
                                        (- height thickness bvsurf-rect.h))))
    (setv ppsurf-rect (ppsurf.get-rect
                        :bottomright (, (- width thickness)
                                        (- height thickness
                                          bvsurf-rect.h
                                          bpsurf-rect.h))))
    (setv pdsurf-rect (pdsurf.get-rect
                        :bottomright (, (- width thickness)
                                        (- height thickness
                                          bvsurf-rect.h
                                          bpsurf-rect.h
                                          ppsurf-rect.h))))
    (self.surface.blits
      [
       (, pdsurf pdsurf-rect)
       (, ppsurf ppsurf-rect)
       (, bpsurf bpsurf-rect)
       (, bvsurf bvsurf-rect)
       ])
    ; flip buffers
    (pygame.display.flip)))

(defmain [&rest args]
  (setv game (Game))
  (setv success (game.initialize))
  (if success (game.run-loop))
  (game.shutdown))
