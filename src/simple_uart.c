/* Copyright (c) 2009 Nordic Semiconductor. All Rights Reserved.
 *
 * The information contained herein is property of Nordic Semiconductor ASA.
 * Terms and conditions of usage are described in detail in NORDIC
 * SEMICONDUCTOR STANDARD SOFTWARE LICENSE AGREEMENT.
 *
 * Licensees are granted free, non-transferable use of the information. NO
 * WARRANTY of ANY KIND is provided. This heading must NOT be removed from
 * the file.
 *
 */  
  
#include "nrf.h"
#include "simple_uart.h"
#include "nrf_delay.h"
#include "nrf_gpio.h"
#include "board.h"


UART0_IRQHandler(void) 
{
  
//      nrf_gpio_pin_toggle(LED_RGB_BLUE);
//      nrf_gpio_pin_toggle(LED_RGB_RED);
    simple_uart_put(simple_uart_get());

{
  
    
    
      // Wait for RXD data to be received
    }
  
  


{
  
  
    
    
      
      
        // wait in 1ms chunk before checking for status
        nrf_delay_us(1000);
      
    
    else
      
      
      
      
    
  
    
    
      // clear the event and set rx_data with received byte
      NRF_UART0->EVENTS_RXDRDY = 0;
    
    
  


simple_uart_put(uint8_t cr) 
{
  
  
    
    
      // Wait for TXD data to be sent
    }
  


uint32_t
_write(int fd, char * str, int len){
	int i;
	for (i = 0; i < len; i++){
		simple_uart_put(str[i]);
	}
	return len;
}
simple_uart_putstring(const uint8_t * str) 
{








simple_uart_config(uint8_t rts_pin_number, 
                   
                   
{
  
/** @snippet [Configure UART RX and TX pin] */ 
    nrf_gpio_cfg_output(txd_pin_number);
  



	/** @snippet [Configure UART RX and TX pin] */
		if(hwfc)













	#if 1
		// Enable UART interrupt
		NRF_UART0->INTENCLR = 0xffffffffUL;

		(UART_INTENSET_RXDRDY_Set << UART_INTENSET_RXDRDY_Pos)
		// | (UART_INTENSET_TXDRDY_Set << UART_INTENSET_TXDRDY_Pos)
		// | (UART_INTENSET_ERROR_Set << UART_INTENSET_ERROR_Pos)
		;



  
#endif  /* 

