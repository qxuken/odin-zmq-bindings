package zeromq

import "core:c"
import "core:fmt"
import "core:mem"

print_zmq_error :: proc(err_number: Maybe(c.int) = nil) {
    code: c.int = err_number.(c.int) or_else errno()
    fmt.eprintfln("Error(%v): %v", code, strerror(code))
}

setsockopt_string :: proc(s: ^Socket, option: Socket_Option, optval: string) -> (ok: bool) {
    return setsockopt(s, option, raw_data(optval), cast(c.int)len(optval)) == 0
}

recv_msg :: proc(s: ^Socket, allocator := context.allocator) -> []byte {
    msg := Message{}
    rc := msg_init(&msg)
    assert(rc == 0)
    defer msg_close(&msg)
    size := msg_recv(&msg, s, .None)
    if size == -1 do return nil
    buf := make([]byte, size, allocator = allocator)
    mem.copy(raw_data(buf), msg_data(&msg), cast(int)size)
    return buf
}

recv_string :: proc(s: ^Socket, allocator := context.allocator) -> string {
    buf := recv_msg(s, allocator = allocator)
    return string(buf)
}

send_empty :: proc(s: ^Socket) -> (ok: bool) {
    msg := Message{}
    rc := msg_init(&msg)
    assert(rc == 0)
    defer msg_close(&msg)
    return msg_send(&msg, s, .None) == 0
}

send_msg :: proc(s: ^Socket, buf: []byte, opt: Send_Recv_Options = .None) -> (ok: bool) {
    msg := Message{}
    rc := msg_init_size(&msg, cast(c.int)len(buf))
    assert(rc == 0)
    defer msg_close(&msg)
    mem.copy(msg_data(&msg), raw_data(buf), len(buf))
    return msg_send(&msg, s, opt) == cast(i32)len(buf)
}

send_string :: proc(s: ^Socket, val: string, opt: Send_Recv_Options = .None) -> (ok: bool) {
    return send_msg(s, transmute([]byte)val, opt)
}

send_string_more :: proc(s: ^Socket, val: string) -> (ok: bool) {
    return send_msg(s, transmute([]byte)val, .SNDMORE)
}
