package main

import zmq "../zeromq"
import "core:fmt"
import "core:os"
import "core:time"

ADDR :: "tcp://127.0.0.1:53534"

main :: proc() {
	ctx := zmq.ctx_new()
	defer zmq.ctx_term(ctx)

	publisher := zmq.socket(ctx, .PUB)
	defer zmq.close(publisher)

	if rc := zmq.bind(publisher, ADDR); rc != 0 {
		zmq.print_zmq_error()
		os.exit(1)
	}

	fmt.println("Broadcasting weather data...")

	for {
		for temps in ([]int{23, 32}) {
			for zipcode in 10000 ..= 10001 {
				now_str :=
					time.time_to_rfc3339(
						time.now(),
						allocator = context.temp_allocator,
					) or_else "ERROR_TIME"
				str := fmt.tprintf("%05d %d at %v", zipcode, temps, now_str)
				send_ok := zmq.send_string(publisher, str)
				assert(send_ok)
			}
		}
		free_all(context.temp_allocator)
		time.sleep(time.Millisecond * 10)
	}
}
