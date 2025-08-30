# Comunicaciones Digitales UMNG / jose.rugeles@unimilitar.edu.co
# Muestreo ADC con N muestras/periodo y CSV (limpio)
# Raspberry Pi Pico 2 W (RP2350) - MicroPython

import machine
import utime

# ========= Parámetros de configuración =========
ADC_PIN       = 26        # GP26 -> ADC0
VREF          = 3.300     # Mida en 3V3 (pin 36) y reemplace para mejor exactitud
SIGNAL_FREQ   = 50.0     # Hz
SAMPLES_PER_PERIOD = 20   # N muestras por periodo
PERIODS       = 2         # >= 2
OUT_CSV       = "adc_capture_2.csv"
LED_PIN       = "LED"     # LED integrado
# ===============================================

# Derivados
FS_HZ   = SIGNAL_FREQ * SAMPLES_PER_PERIOD
TS_US   = int(1_000_000 / FS_HZ)          # periodo de muestreo (us) truncado
NSAMPS  = int(PERIODS * SAMPLES_PER_PERIOD)

adc = machine.ADC(ADC_PIN)
led = machine.Pin(LED_PIN, machine.Pin.OUT)

print("-------------------------------------------")
print("Captura ADC - N muestras por periodo (CSV limpio)")
print(f"f_señal = {SIGNAL_FREQ} Hz")
print(f"N/periodo = {SAMPLES_PER_PERIOD}")
print(f"Periodos a capturar = {PERIODS}")
print(f"Frecuencia de muestreo fs (teórica) = {FS_HZ:.1f} Hz")
print(f"Periodo de muestreo Ts (trunc) = {TS_US} us")
print(f"N total de muestras = {NSAMPS}")
print(f"Voltaje de referencia VREF = {VREF:.4f} V")
print("-------------------------------------------")
input("Presione ENTER para iniciar la captura...")

# --- Calentamiento ADC ---
_ = adc.read_u16()
utime.sleep_ms(10)

# --- Métricas internas (no se escriben al CSV) ---
overruns = 0
t_first_rel = None
t_last_rel  = None

# --- Captura y escritura en streaming ---
with open(OUT_CSV, "w") as f:
    # Cabecera simplificada
    f.write("n,t_us,dec,bin,hex,volts\n")

    t0 = utime.ticks_us()
    next_t = t0
    led.value(1)

    for n in range(NSAMPS):
        # Espera activa hasta el instante objetivo
        while utime.ticks_diff(utime.ticks_us(), next_t) < 0:
            pass

        t_sample = utime.ticks_us()
        # late (solo para métricas internas)
        if utime.ticks_diff(t_sample, next_t) > 0:
            overruns += 1

        raw16  = adc.read_u16()
        code12 = raw16 >> 4
        volts  = (code12 * VREF) / 4095.0

        bin12s = f"{code12:012b}"
        hex12  = f"0x{code12:03X}"

        t_rel = utime.ticks_diff(t_sample, t0)  # us desde inicio
        if t_first_rel is None:
            t_first_rel = t_rel
        t_last_rel = t_rel

        # Escribir línea (CSV limpio)
        f.write(f"{n},{t_rel},{code12},{bin12s},{hex12},{volts:.6f}\n")

        # Programar siguiente muestra
        next_t = utime.ticks_add(next_t, TS_US)

    led.value(0)

# --- Reporte final (en consola, no en el CSV) ---
if NSAMPS > 1 and t_last_rel is not None and t_first_rel is not None and t_last_rel > t_first_rel:
    fs_real = 1_000_000.0 * (NSAMPS - 1) / (t_last_rel - t_first_rel)
else:
    fs_real = 0.0

print("\n✅ Captura finalizada.")
print(f"Archivo CSV: {OUT_CSV}")
print("Columnas: n, t_us, dec, bin, hex, volts")
print("----- Métricas internas (no incluidas en el CSV) -----")
print(f"Overruns (llegadas tarde): {overruns} de {NSAMPS} muestras")
print(f"fs_real ≈ {fs_real:.1f} Hz (vs fs_teórica = {FS_HZ:.1f} Hz)")
print("-------------------------------------------")
print("Nota: si hay muchos overruns, reduzca N/periodo o la frecuencia de la señal.")
