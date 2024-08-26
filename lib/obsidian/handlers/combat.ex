defmodule Obsidian.Handlers.Combat do
  import Obsidian.Util, only: [send_packet: 1]

  require Logger

  @cmsg_switch_stance 40

  def handle_packet(@cmsg_switch_stance, payload, state) do
    <<stance_id::integer-8, _trigger_action::integer-8, _rest::binary>> = payload

    send_packet(Obsidian.Packets.SwitchCombatStance.bytes(state.character, stance_id, 0))

    {:continue, state}
  end
end
