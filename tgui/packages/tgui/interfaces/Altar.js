import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

export const Altar = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window title="Altar" width={450} height={450}>
      <Window.Content>
        <Button content="Summon Light" onClick={() => act("light")} />
      </Window.Content>
    </Window>
  );
};