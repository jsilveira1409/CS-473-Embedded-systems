library ieee;
use ieee.std_logic_1164.all;

-- Testbench entity
entity testbench is
end testbench;

-- Testbench architecture
architecture behavior of testbench is

  -- Declare signals for testbench
  signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal start : std_logic := '0';
  signal done : std_logic;
  signal source_address, destination_address : std_logic_vector(31 downto 0);
  signal data_in, data_out : std_logic_vector(7 downto 0);

begin

  -- Instantiate DMA module
  dma_inst : entity work.dma
    port map (
      clk => clk,
      reset => reset,
      start => start,
      done => done,
      source_address => source_address,
      destination_address => destination_address,
      data_in => data_in,
      data_out => data_out
    );

  -- Clock process
  clk_process : process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

  -- Test sequence
  test_sequence : process
  begin
    -- Reset DMA module
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- Set source and destination addresses
    source_address <= "0000000000000001";
    destination_address <= "1000000000000001";

    -- Set data to be transferred
    data_in <= "00000001";

    -- Start DMA transfer
    start <= '1';
    wait for 20 ns;
    start <= '0';

    -- Wait for DMA transfer to complete
    wait until done = '1';

    -- Check that data was transferred correctly
    assert data_out = "00000001"
      report "ERROR: Data transfer failed"
      severity error;

    -- End test
    wait;
  end process;

end behavior;
