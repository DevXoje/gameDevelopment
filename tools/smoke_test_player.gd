## smoke_test_player.gd
## Script de verificación (smoke test) para el vertical slice de movimiento del jugador.
##
## Propósito:
##   Instancia Main.tscn, simula inputs de movimiento durante varios frames y verifica
##   que la posición del jugador ha cambiado. Si falla, imprime un mensaje de error.
##
## Cómo ejecutar localmente:
##   1. Asegurarse de tener Godot 4.6 instalado y accesible como `godot` en el PATH.
##   2. Desde la raíz del proyecto (gameDevelopment/):
##
##      godot --headless --path papa-gallo --script tools/smoke_test_player.gd
##
##   3. Resultado esperado en la consola:
##      [SmokeTest] ✅ PASÓ — El jugador se movió. Posición inicial: (640, 360) → final: (posición distinta)
##
##   4. Si falla:
##      [SmokeTest] ❌ FALLÓ — El jugador NO se movió. Posición inicial == final: (640, 360)
##
## Nota: Este script requiere que el Input Map esté configurado en project.godot
## con las acciones move_right y move_up. Consultar docs/INPUT_MAP.md.
##
## TODO: Añadir verificación de colisión (el jugador no debe atravesar el suelo).
## TODO: Integrar en pipeline CI cuando haya servidor headless disponible.

extends SceneTree

## Número de frames de física a simular antes de verificar.
const FRAMES_TO_SIMULATE: int = 30

## Velocidad esperada mínima de desplazamiento (en píxeles) tras los frames simulados.
const MIN_EXPECTED_DISPLACEMENT: float = 1.0

func _init() -> void:
	print("[SmokeTest] Iniciando smoke test de movimiento del jugador...")

	# Cargar Main.tscn
	var main_scene_path := "res://scenes/Main.tscn"
	var packed_scene: PackedScene = load(main_scene_path)
	if packed_scene == null:
		push_error("[SmokeTest] ❌ ERROR — No se pudo cargar '%s'. ¿Existe la escena?" % main_scene_path)
		quit(1)
		return

	# Instanciar la escena principal
	var main_instance: Node = packed_scene.instantiate()
	root.add_child(main_instance)

	# Buscar el nodo Player dentro de la escena
	var player: CharacterBody2D = main_instance.get_node_or_null("Player")
	if player == null:
		push_error("[SmokeTest] ❌ ERROR — No se encontró el nodo 'Player' en '%s'." % main_scene_path)
		quit(1)
		return

	# Registrar posición inicial
	var initial_position: Vector2 = player.global_position
	print("[SmokeTest] Posición inicial del jugador: %s" % initial_position)

	# Simular inputs: mover derecha (move_right) y arriba (move_up) durante FRAMES_TO_SIMULATE frames.
	# InputMap.action_press() simula que la acción está siendo presionada.
	Input.action_press("move_right")
	Input.action_press("move_up")

	# Procesar física por FRAMES_TO_SIMULATE ticks
	for i in range(FRAMES_TO_SIMULATE):
		process_frame()  # Avanza un frame de proceso
		physics_frame()  # Avanza un tick de física

	# Soltar inputs
	Input.action_release("move_right")
	Input.action_release("move_up")

	# Verificar que la posición cambió
	var final_position: Vector2 = player.global_position
	var displacement: float = initial_position.distance_to(final_position)

	print("[SmokeTest] Posición final del jugador: %s" % final_position)
	print("[SmokeTest] Desplazamiento total: %.2f px" % displacement)

	if displacement >= MIN_EXPECTED_DISPLACEMENT:
		print("[SmokeTest] ✅ PASÓ — El jugador se movió correctamente.")
		print("[SmokeTest]    Posición inicial: %s → final: %s" % [initial_position, final_position])
		quit(0)
	else:
		push_error("[SmokeTest] ❌ FALLÓ — El jugador NO se movió (desplazamiento: %.2f px, mínimo esperado: %.2f px)." % [displacement, MIN_EXPECTED_DISPLACEMENT])
		push_error("[SmokeTest]    Posición inicial: %s | Posición final: %s" % [initial_position, final_position])
		quit(1)
