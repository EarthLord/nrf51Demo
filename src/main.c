#include "simple_uart.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"
#include "nrf.h"
#include "leds.h"
#include "board.h"
#include "clock-nrf.h"
#include "rtimer-arch.h"

int main(void)
{
	unsigned int i = 7;

	float ab = 1.29;

	leds_init();

	leds_blink();

    simple_uart_config(RTS_PIN_NUMBER, TX_PIN_NUMBER, CTS_PIN_NUMBER, RX_PIN_NUMBER, UART_BAUDRATE_BAUDRATE_Baud38400, 12, HWFC);

    printf("A printf test: %.3f %d\n", ab, i);
    clock_init();
    printf(" \r\nStart:\r\n");
    nrf_clock_set_seconds(5);
    nrf_clock_update_expiration_time(327680);
    rtimer_arch_init();

  while(true) {
   // __WFI();
#if 0
	  i  = clock_time();
	  printf("%d\n",i);
	  clock_delay(1000);
#endif
  }
}
