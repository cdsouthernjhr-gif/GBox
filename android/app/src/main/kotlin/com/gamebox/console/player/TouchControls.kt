package com.gamebox.console.player

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.view.HapticFeedbackConstants
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.min

/**
 * On-screen controls for phones and tablets: a D-pad on the left, the
 * console's face buttons on the right, Select/Start and a menu button at
 * the top. Multi-touch; sliding a finger across the D-pad changes direction.
 * Key codes sent are those LibretroDroid understands (RetroPad layout).
 */
@SuppressLint("ViewConstructor")
class TouchControls(
    context: Context,
    private val layout: Layout,
    private val send: (action: Int, keyCode: Int) -> Unit,
    private val sendMotion: (source: Int, x: Float, y: Float) -> Unit,
    private val onMenu: () -> Unit,
) : View(context) {

    /** A face/shoulder button at a position relative to the right cluster. */
    data class Button(val key: Int, val label: String, val dx: Float, val dy: Float)

    /**
     * [analog]: the left circle is an analog stick (N64, PSP) instead of a
     * D-pad. [passThrough]: touches outside the controls reach the game
     * (Nintendo DS touch screen).
     */
    data class Layout(
        val buttons: List<Button>,
        val shoulders: List<Button> = emptyList(),
        val analog: Boolean = false,
        val passThrough: Boolean = false,
    )

    companion object {
        private const val A = KeyEvent.KEYCODE_BUTTON_A
        private const val B = KeyEvent.KEYCODE_BUTTON_B
        private const val X = KeyEvent.KEYCODE_BUTTON_X
        private const val Y = KeyEvent.KEYCODE_BUTTON_Y

        // Diamond positions (units of button spacing): right, bottom, left, top.
        private val right = 1f to 0f
        private val bottom = 0f to 1f
        private val left = -1f to 0f
        private val top = 0f to -1f

        private fun btn(key: Int, label: String, p: Pair<Float, Float>) = Button(key, label, p.first, p.second)

        // N64 C-buttons: the right analog stick of the RetroPad.
        const val C_UP = -101
        const val C_DOWN = -102
        const val C_LEFT = -103
        const val C_RIGHT = -104
        private val C_KEYS = setOf(C_UP, C_DOWN, C_LEFT, C_RIGHT)

        fun layoutFor(name: String): Layout = when (name) {
            "snes" -> Layout(
                listOf(btn(A, "A", right), btn(B, "B", bottom), btn(Y, "Y", left), btn(X, "X", top)),
                listOf(Button(KeyEvent.KEYCODE_BUTTON_L1, "L", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R", 0f, 0f)),
            )
            "gba" -> Layout(
                listOf(Button(A, "A", 0.6f, -0.4f), Button(B, "B", -0.6f, 0.4f)),
                listOf(Button(KeyEvent.KEYCODE_BUTTON_L1, "L", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R", 0f, 0f)),
            )
            // Genesis Plus GX RetroPad mapping: Y = A, B = B, A = C.
            "md" -> Layout(listOf(Button(Y, "A", -1.1f, 0.3f), Button(B, "B", 0f, 0f), Button(A, "C", 1.1f, -0.3f)))
            "ps1" -> Layout(
                listOf(btn(A, "○", right), btn(B, "✕", bottom), btn(Y, "□", left), btn(X, "△", top)),
                listOf(
                    Button(KeyEvent.KEYCODE_BUTTON_L1, "L1", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R1", 0f, 0f),
                    Button(KeyEvent.KEYCODE_BUTTON_L2, "L2", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R2, "R2", 0f, 0f),
                ),
            )
            // Mupen64Plus RetroPad: A = A, B = B, L2 = Z, right stick = C.
            "n64" -> Layout(
                listOf(
                    Button(A, "A", 0.2f, 0.9f), Button(B, "B", -0.9f, 0.4f),
                    Button(C_UP, "C▲", 0.6f, -1.2f), Button(C_DOWN, "C▼", 0.6f, -0.2f),
                    Button(C_LEFT, "C◀", 0.0f, -0.7f), Button(C_RIGHT, "C▶", 1.2f, -0.7f),
                ),
                listOf(
                    Button(KeyEvent.KEYCODE_BUTTON_L1, "L", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R", 0f, 0f),
                    Button(KeyEvent.KEYCODE_BUTTON_L2, "LZ", 0f, 0f),
                ),
                analog = true,
            )
            "psp" -> Layout(
                listOf(btn(A, "○", right), btn(B, "✕", bottom), btn(Y, "□", left), btn(X, "△", top)),
                listOf(Button(KeyEvent.KEYCODE_BUTTON_L1, "L", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R", 0f, 0f)),
                analog = true,
            )
            // Nintendo DS: X/Y/A/B, L/R; the touch screen stays touchable.
            "nds" -> Layout(
                listOf(btn(A, "A", right), btn(B, "B", bottom), btn(Y, "Y", left), btn(X, "X", top)),
                listOf(Button(KeyEvent.KEYCODE_BUTTON_L1, "L", 0f, 0f), Button(KeyEvent.KEYCODE_BUTTON_R1, "R", 0f, 0f)),
                passThrough = true,
            )
            // NES and Game Boy: B and A side by side.
            else -> Layout(listOf(Button(A, "A", 0.6f, -0.4f), Button(B, "B", -0.6f, 0.4f)))
        }

        /** Marker for "this pointer is on the analog stick". */
        private const val STICK = -200

        private val DPAD = listOf(
            KeyEvent.KEYCODE_DPAD_UP, KeyEvent.KEYCODE_DPAD_DOWN, KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.KEYCODE_DPAD_RIGHT,
        )
    }

    private val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0x55FFFFFF }
    private val pressedFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0x99FFFFFF.toInt() }
    private val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xDD000000.toInt()
        textAlign = Paint.Align.CENTER
        isFakeBoldText = true
    }

    private data class Target(val key: Int, val label: String, val rect: RectF, val round: Boolean)

    private var targets = listOf<Target>()
    private var dpadCenter = 0f to 0f
    private var dpadRadius = 0f

    /** Keys currently held by each pointer id. */
    private val held = HashMap<Int, Set<Int>>()
    private var pressed = setOf<Int>()

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        val unit = min(w, h) / 9f
        val margin = unit * 0.5f
        dpadRadius = unit * 1.5f
        dpadCenter = (margin + dpadRadius) to (h - margin - dpadRadius)
        val r = unit * 0.62f
        val cx = w - margin - unit * 1.6f
        val cy = h - margin - unit * 1.6f
        val list = mutableListOf<Target>()
        for (b in layout.buttons) {
            val x = cx + b.dx * unit * 1.1f
            val y = cy + b.dy * unit * 1.1f
            list += Target(b.key, b.label, RectF(x - r, y - r, x + r, y + r), true)
        }
        // Shoulders: L buttons top-left, R buttons top-right.
        val sw = unit * 1.5f
        val sh = unit * 0.7f
        var li = 0
        var ri = 0
        for (b in layout.shoulders) {
            val isLeft = b.label.startsWith("L") || b.label.startsWith("Z")
            val row = if (isLeft) li++ else ri++
            val top = unit * 1.3f + row * (sh + unit * 0.2f)
            val rect = if (isLeft) RectF(margin, top, margin + sw, top + sh) else RectF(w - margin - sw, top, w - margin, top + sh)
            list += Target(b.key, b.label, rect, false)
        }
        // Select / Start bottom centre, menu top centre.
        val bw = unit * 1.3f
        val bh = unit * 0.5f
        val by = h - margin - bh
        list += Target(KeyEvent.KEYCODE_BUTTON_SELECT, "SELECT", RectF(w / 2f - bw - unit * 0.15f, by, w / 2f - unit * 0.15f, by + bh), false)
        list += Target(KeyEvent.KEYCODE_BUTTON_START, "START", RectF(w / 2f + unit * 0.15f, by, w / 2f + bw + unit * 0.15f, by + bh), false)
        list += Target(KeyEvent.KEYCODE_BUTTON_MODE, "☰", RectF(w / 2f - unit * 0.5f, margin * 0.5f, w / 2f + unit * 0.5f, margin * 0.5f + bh), false)
        targets = list
        text.textSize = unit * 0.35f
    }

    override fun onDraw(canvas: Canvas) {
        val (dx, dy) = dpadCenter
        canvas.drawCircle(dx, dy, dpadRadius, fill)
        if (layout.analog) {
            canvas.drawCircle(dx + stick.first * dpadRadius * 0.6f, dy + stick.second * dpadRadius * 0.6f,
                dpadRadius * 0.42f, if (stick != 0f to 0f) pressedFill else fill)
            drawButtons(canvas)
            return
        }
        val arm = dpadRadius * 0.62f
        for ((key, ox, oy) in listOf(
            Triple(KeyEvent.KEYCODE_DPAD_UP, 0f, -arm), Triple(KeyEvent.KEYCODE_DPAD_DOWN, 0f, arm),
            Triple(KeyEvent.KEYCODE_DPAD_LEFT, -arm, 0f), Triple(KeyEvent.KEYCODE_DPAD_RIGHT, arm, 0f),
        )) {
            canvas.drawCircle(dx + ox, dy + oy, dpadRadius * 0.3f, if (key in pressed) pressedFill else fill)
        }
        drawButtons(canvas)
    }

    private fun drawButtons(canvas: Canvas) {
        for (t in targets) {
            val p = if (t.key in pressed) pressedFill else fill
            if (t.round) canvas.drawOval(t.rect, p) else canvas.drawRoundRect(t.rect, 18f, 18f, p)
            canvas.drawText(t.label, t.rect.centerX(), t.rect.centerY() + text.textSize / 3, text)
        }
    }

    /** Current analog stick position, -1..1 on each axis. */
    private var stick = 0f to 0f
    private var stickPointer: Int? = null

    private fun keysAt(x: Float, y: Float): Set<Int> {
        val (cx, cy) = dpadCenter
        val ddx = x - cx
        val ddy = y - cy
        if (layout.analog && hypot(ddx, ddy) <= dpadRadius * 1.15f) return setOf(STICK)
        if (hypot(ddx, ddy) <= dpadRadius * 1.15f) {
            val dead = dpadRadius * 0.2f
            val keys = mutableSetOf<Int>()
            // 8 directions: diagonals when both axes are clearly pushed.
            if (abs(ddx) > dead && abs(ddx) > abs(ddy) * 0.5f) keys += if (ddx < 0) KeyEvent.KEYCODE_DPAD_LEFT else KeyEvent.KEYCODE_DPAD_RIGHT
            if (abs(ddy) > dead && abs(ddy) > abs(ddx) * 0.5f) keys += if (ddy < 0) KeyEvent.KEYCODE_DPAD_UP else KeyEvent.KEYCODE_DPAD_DOWN
            return keys
        }
        for (t in targets) {
            val hit = if (t.round) {
                hypot(x - t.rect.centerX(), y - t.rect.centerY()) <= t.rect.width() * 0.65f
            } else {
                t.rect.contains(x, y)
            }
            if (hit) return setOf(t.key)
        }
        return emptySet()
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        // DS touch screen: a touch that starts outside every control goes to
        // the game underneath.
        if (layout.passThrough && event.actionMasked == MotionEvent.ACTION_DOWN && keysAt(event.x, event.y).isEmpty()) {
            return false
        }
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN, MotionEvent.ACTION_MOVE -> {
                for (i in 0 until event.pointerCount) {
                    val id = event.getPointerId(i)
                    val keys = keysAt(event.getX(i), event.getY(i))
                    if (STICK in keys || stickPointer == id) {
                        if (stickPointer == null || stickPointer == id) {
                            stickPointer = id
                            moveStick(event.getX(i), event.getY(i))
                        }
                        held[id] = emptySet()
                    } else {
                        held[id] = keys
                    }
                }
            }
            MotionEvent.ACTION_POINTER_UP -> {
                val id = event.getPointerId(event.actionIndex)
                held.remove(id)
                if (stickPointer == id) releaseStick()
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                held.clear()
                releaseStick()
            }
        }
        val now = held.values.flatten().toSet()
        if (KeyEvent.KEYCODE_BUTTON_MODE in now && KeyEvent.KEYCODE_BUTTON_MODE !in pressed) onMenu()
        val core = now - KeyEvent.KEYCODE_BUTTON_MODE
        val before = pressed - KeyEvent.KEYCODE_BUTTON_MODE
        for (k in before - core) if (k !in C_KEYS) send(KeyEvent.ACTION_UP, k)
        for (k in core - before) {
            if (k !in C_KEYS) send(KeyEvent.ACTION_DOWN, k)
            if (k !in DPAD) performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
        }
        // C-buttons drive the right stick.
        if ((core intersect C_KEYS) != (before intersect C_KEYS)) {
            val cx = (if (C_RIGHT in core) 1f else 0f) - (if (C_LEFT in core) 1f else 0f)
            val cy = (if (C_DOWN in core) 1f else 0f) - (if (C_UP in core) 1f else 0f)
            sendMotion(com.swordfish.libretrodroid.GLRetroView.MOTION_SOURCE_ANALOG_RIGHT, cx, cy)
        }
        if (now != pressed) {
            pressed = now
            invalidate()
        }
        return true
    }

    private fun moveStick(x: Float, y: Float) {
        val (cx, cy) = dpadCenter
        val nx = ((x - cx) / (dpadRadius * 0.8f)).coerceIn(-1f, 1f)
        val ny = ((y - cy) / (dpadRadius * 0.8f)).coerceIn(-1f, 1f)
        stick = nx to ny
        sendMotion(com.swordfish.libretrodroid.GLRetroView.MOTION_SOURCE_ANALOG_LEFT, nx, ny)
        invalidate()
    }

    private fun releaseStick() {
        if (stickPointer == null && stick == 0f to 0f) return
        stickPointer = null
        stick = 0f to 0f
        sendMotion(com.swordfish.libretrodroid.GLRetroView.MOTION_SOURCE_ANALOG_LEFT, 0f, 0f)
        invalidate()
    }
}
