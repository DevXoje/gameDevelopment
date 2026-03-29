#!/usr/bin/env -S godot --headless --script
## check_input_map.gd
## Script de verificación del Input Map de PapaGallo
## Motor: Godot 4.6
##
## USO DESDE LÍNEA DE COMANDOS (desde la carpeta papa-gallo/):
##   godot --headless --script ../tools/check_input_map.gd
##
## USO DESDE EL EDITOR GODOT:
##   1. Abrir el editor Godot con el proyecto papa-gallo/
##   2. Ir a: Script → File → Open... → seleccionar tools/check_input_map.gd
##   3. Presionar Ctrl+Shift+X  (o el botón "Run" en el script editor)
##   NOTA: Desde el editor, la salida aparece en la pestaña "Output" (parte inferior)
##
## USO ALTERNATIVO (adjuntar a un nodo en escena de prueba):
##   1. Crear una escena vacía (Scene → New Scene)
##   2. Agregar un nodo Node raíz
##   3. Adjuntar este script al nodo (o usar la versión _ready() de docs/INPUT_README.md)
##   4. Ejecutar la escena con F5
##
## SALIDA ESPERADA (si el Input Map está correctamente aplicado):
##   === VERIFICACIÓN INPUT MAP — PapaGallo ===
##   [INPUT] ✓ move_up         — 3 binding(s): Key(W), Key(Up), JoyMotion(axis:1 val:-1.0)
##   [INPUT] ✓ move_down       — 3 binding(s): Key(S), Key(Down), JoyMotion(axis:1 val:1.0)
##   [INPUT] ✓ move_left       — 3 binding(s): Key(A), Key(Left), JoyMotion(axis:0 val:-1.0)
##   [INPUT] ✓ move_right      — 3 binding(s): Key(D), Key(Right), JoyMotion(axis:0 val:1.0)
##   [INPUT] ✓ attack_primary  — 4 binding(s): Key(J), Key(Z), MouseBtn(1), JoyBtn(5)
##   [INPUT] ✓ attack_secondary— 4 binding(s): Key(K), Key(X), MouseBtn(2), JoyMotion(axis:5 val:1.0)
##   [INPUT] ✓ change_weapon   — 4 binding(s): Key(Tab), Key(Q), MouseBtn(4), JoyBtn(3)
##   [INPUT] ✓ sprint          — 3 binding(s): Key(Shift L), Key(Shift R), JoyBtn(1)
##   [INPUT] ✓ interact        — 3 binding(s): Key(E), Key(F), JoyBtn(0)
##   [INPUT] ✓ pause           — 3 binding(s): Key(Esc), Key(P), JoyBtn(6)
##   ------------------------------------------
##   [INPUT] ✅ Todas las acciones verificadas (10/10 con bindings).
##   [DEBUG] ℹ debug_next_wave y debug_spawn_enemy se registran en código (DebugManager.gd)

extends SceneTree

# Acciones requeridas con número mínimo de bindings esperados
const ACCIONES_REQUERIDAS: Dictionary = {
	"move_up":          {"min_bindings": 3, "nota": "W / Up / Stick-Iz-Up"},
	"move_down":        {"min_bindings": 3, "nota": "S / Down / Stick-Iz-Down"},
	"move_left":        {"min_bindings": 3, "nota": "A / Left / Stick-Iz-Left"},
	"move_right":       {"min_bindings": 3, "nota": "D / Right / Stick-Iz-Right"},
	"attack_primary":   {"min_bindings": 4, "nota": "J / Z / Click-Izq / RB"},
	"attack_secondary": {"min_bindings": 4, "nota": "K / X / Click-Der / RT"},
	"change_weapon":    {"min_bindings": 4, "nota": "Tab / Q / Wheel-Up / Y"},
	"sprint":           {"min_bindings": 3, "nota": "Shift-L / Shift-R / B"},
	"interact":         {"min_bindings": 3, "nota": "E / F / A-button"},
	"pause":            {"min_bindings": 3, "nota": "Escape / P / Start"},
}

# Acciones de debug (solo en builds de desarrollo, registradas en código)
const ACCIONES_DEBUG: Array = ["debug_next_wave", "debug_spawn_enemy"]


func _initialize() -> void:
	print("")
	print("=== VERIFICACIÓN INPUT MAP — PapaGallo ===")
	print("    Motor: Godot 4.6 | Fecha: " + Time.get_date_string_from_system())
	print("==========================================")
	print("")

	var errores: int = 0
	var advertencias: int = 0
	var ok_count: int = 0

	for action_name in ACCIONES_REQUERIDAS:
		var config: Dictionary = ACCIONES_REQUERIDAS[action_name]
		var min_bindings: int = config["min_bindings"]
		var nota: String = config["nota"]

		if not InputMap.has_action(action_name):
			print("[INPUT] ✗ %-20s — FALTANTE (acción no registrada en project.godot)" % action_name)
			errores += 1
			continue

		var events: Array = InputMap.action_get_events(action_name)
		var count: int = events.size()

		if count == 0:
			print("[INPUT] ⚠ %-20s — Sin bindings (acción existe pero vacía)" % action_name)
			advertencias += 1
			continue

		# Construir lista de bindings para mostrar
		var binding_labels: Array = []
		for event in events:
			binding_labels.append(_describe_event(event))

		var label_str: String = ", ".join(binding_labels)

		if count >= min_bindings:
			print("[INPUT] ✓ %-20s — %d binding(s): %s" % [action_name, count, label_str])
			ok_count += 1
		else:
			print("[INPUT] ⚠ %-20s — %d binding(s) (esperados >=%d): %s" % [action_name, count, min_bindings, label_str])
			print("          Nota: se esperaban: %s" % nota)
			advertencias += 1

	# Verificar acciones de debug (informativo, no error si faltan)
	print("")
	print("--- Acciones de Debug (solo modo desarrollo) ---")
	for debug_action in ACCIONES_DEBUG:
		if InputMap.has_action(debug_action):
			var events: Array = InputMap.action_get_events(debug_action)
			print("[DEBUG] ✓ %-22s — %d binding(s) (registrada en project.godot)" % [debug_action, events.size()])
		else:
			print("[DEBUG] ℹ %-22s — No registrada (esperado: se añade en código vía DebugManager.gd)" % debug_action)

	print("")
	print("==========================================")
	print("    RESUMEN:")
	print("    ✓ OK:          %d / %d acciones" % [ok_count, ACCIONES_REQUERIDAS.size()])
	if advertencias > 0:
		print("    ⚠ ADVERTENCIAS: %d" % advertencias)
	if errores > 0:
		print("    ✗ ERRORES:    %d" % errores)

	if errores == 0 and advertencias == 0:
		print("")
		print("    ✅ Todas las acciones verificadas correctamente.")
		print("       El Input Map está listo para usar en PapaGallo.")
	elif errores == 0 and advertencias > 0:
		print("")
		print("    ⚠ Input Map aplicado con advertencias.")
		print("      Revisa los bindings marcados con ⚠ arriba.")
	else:
		print("")
		print("    ❌ Input Map incompleto. Verifica project.godot y")
		print("       vuelve a ejecutar este script.")

	print("==========================================")
	print("")
	quit()


## Describe un InputEvent de forma legible
func _describe_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		var key_str: String = ""
		if key_event.physical_keycode != 0:
			key_str = OS.get_keycode_string(key_event.physical_keycode)
		elif key_event.keycode != 0:
			key_str = OS.get_keycode_string(key_event.keycode)
		else:
			key_str = "Key(?)"
		if key_event.location == 1:
			key_str += "-L"
		elif key_event.location == 2:
			key_str += "-R"
		return "Key(%s)" % key_str

	elif event is InputEventMouseButton:
		var mb_event: InputEventMouseButton = event as InputEventMouseButton
		var btn_names: Dictionary = {
			1: "Click-Izq", 2: "Click-Der", 3: "Click-Med",
			4: "Wheel-Up", 5: "Wheel-Down"
		}
		var btn_label: String = btn_names.get(mb_event.button_index, "MouseBtn(%d)" % mb_event.button_index)
		return "Mouse(%s)" % btn_label

	elif event is InputEventJoypadButton:
		var joy_btn: InputEventJoypadButton = event as InputEventJoypadButton
		var btn_labels: Dictionary = {
			0: "A", 1: "B", 2: "X", 3: "Y",
			4: "LB", 5: "RB", 6: "Start", 7: "Select",
			8: "L3", 9: "R3"
		}
		var lbl: String = btn_labels.get(joy_btn.button_index, "JoyBtn(%d)" % joy_btn.button_index)
		return "Joy(%s)" % lbl

	elif event is InputEventJoypadMotion:
		var joy_axis: InputEventJoypadMotion = event as InputEventJoypadMotion
		var axis_labels: Dictionary = {
			0: "StickIz-X", 1: "StickIz-Y",
			2: "StickDer-X", 3: "StickDer-Y",
			4: "LT", 5: "RT"
		}
		var dir: String = "+" if joy_axis.axis_value > 0 else "-"
		var axis_lbl: String = axis_labels.get(joy_axis.axis, "Axis%d" % joy_axis.axis)
		return "JoyAxis(%s%s)" % [dir, axis_lbl]

	else:
		return event.as_text()
