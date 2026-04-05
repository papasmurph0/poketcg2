SECTION "SRAM0", SRAM

s0a000:: ; a000
	ds $3

sPrinterContrastLevel:: ; a003
	ds $1

s0a004:: ; a004
	ds $1

sTotalCardPopsDone:: ; a005
	ds $1

sTextSpeed:: ; a006
	ds $1

sDuelAnimationsSetting:: ; a007
	ds $1

s0a008:: ; a008
	ds $1

sSkipDelayAllowed:: ; a009
	ds $1

sClearedGame:: ; a00a
	ds $1

sCoinTossAnimationSetting:: ; a00b
	ds $1

sTextBoxFrameColor:: ; a00c
	ds $1

	ds $3

sPlayerName:: ; a010
	ds NAME_BUFFER_LENGTH

sTotalDuelCounter:: ; a020
	ds $2

; number of link battles the player has played
sLinkDuelCounter:: ; a022
	ds $2

	ds $dc

sCardAndDeckSaveData::

; for each card, how many (0-127) the player owns
; CARD_NOT_OWNED ($80) indicates that the player has not yet seen the card
sCardCollection:: ; a100
	ds CARD_COLLECTION_SIZE

sBuiltDecks::
sDeck1:: deck_struct sDeck1 ; a300
sDeck2:: deck_struct sDeck2 ; a360
sDeck3:: deck_struct sDeck3 ; a3c0
sDeck4:: deck_struct sDeck4 ; a420

	ds $60

sSavedDecks:: ; a4e0
; wSavedDeck1 - wSavedDeck10
FOR n, 1, NUM_DECK_SAVE_MACHINE_SLOTS + 1
sSavedDeck{d:n}:: deck_struct sSavedDeck{d:n}
ENDR

sCurrentlySelectedDeck:: ; b7a0
	ds $1

; keeps track of how many unnamed decks have been built
; as they suffix the number ### in the form of "<PLYAYER>の###デッキ"
; max number is MAX_UNNAMED_DECK_NUM
sUnnamedDeckCounter:: ; b7a1
	ds $2

; each bit represents whether the player has
; obtained a card from a given set
sBoosterPacksObtained:: ; b7a3
	ds $1

	ds $3

sCardAndDeckSaveDataEnd::

	ds $59

sGeneralSaveData:: ; b800

sGeneralSaveDataHeader:: ; b800
	ds $1

; see WRAMToSRAMMapper_GeneralSave
sGeneralSaveDataMain:: ; b801

sGeneralSavePlayTimeCounterFrames:: ; b801
	ds $1

sGeneralSavePlayTimeCounterSeconds:: ; b802
	ds $1

sGeneralSavePlayTimeCounterMinutes:: ; b803
	ds $1

sGeneralSavePlayTimeCounterHours:: ; b804
	ds $2

sGeneralSaveCurMusic:: ; b806
	ds $1

sGeneralSaveNextGameEvent:: ; b807
	ds $1

sGeneralSaveNextWarpMap:: ; b808
	ds $1

sGeneralSaveNextWarpPlayerCoords:: ; b809
	ds $2

sGeneralSavePlayerOWObject:: ; b80b
	ds $1

sGeneralSaveCurMapScriptsBank:: ; b80c
	ds $1

sGeneralSaveCurMapScriptsPointer:: ; b80d
	ds $2

sGeneralSaveOverworldMode:: ; b80f
	ds $1

sGeneralSaveOverworldTransition:: ; b810
	ds $1

sGeneralSavePrevMap:: ; b811
	ds $1

sGeneralSaveTempPrevMap:: ; b812
	ds $1

sGeneralSaveCurMap:: ; b813
	ds $1

sGeneralSaveCurOWLocation:: ; b814
	ds $1

sGeneralSaveCurIsland:: ; b815
	ds $1

sGeneralSavePlayerOWLocation:: ; b816
	ds $1

sGeneralSaveNextMapHeaderData:: ; b817
	ds MAPHEADERSTRUCT_LENGTH

sGeneralSaveNextWarpPlayerData:: ; b81c
	ds $3

sGeneralSaveScriptNPC:: ; b81f
	ds $1

sGeneralSaveScriptNPCName:: ; b820
	ds $2

sGeneralSaveSentMailBitfield:: ; b822
	ds $4

sGeneralSaveTempCardDungeonBet:: ; b826
	ds $1

sGeneralSaveEventVars:: ; b827
	ds EVENT_VAR_BYTES - 2

sGeneralSaveGeneralVars:: ; b859
	ds GENERAL_VAR_BYTES - 2

sGeneralSaveOWData:: ; b877
	ds 177

sGeneralSaveNPCStateBuffer:: ; b928
	ds 5 * MAX_NUM_OW_OBJECTS

sGeneralSaveScrollTargetObject:: ; b95a
	ds $1

sGeneralSaveSelectedCoin:: ; b95b
	ds $1

sGeneralSaveCoinPage:: ; b95c
	ds $1

sGeneralSavePauseMenuCursorPosition:: ; b95d
	ds $1

sGeneralSaveMinicomMenuCursorPosition:: ; b95e
	ds $1

sGeneralSaveGiftCenterMenuCursorPosition:: ; b95f
	ds $1

sGeneralSaveNumMailInQueue:: ; b960
	ds $1

sGeneralSaveMailQueue:: ; b961
	ds MAIL_QUEUE_BUFFER_SIZE

sGeneralSaveMailCount:: ; b97a
	ds $1

sGeneralSaveMailList:: ; b97b
	ds MAIL_BUFFER_SIZE

sGeneralSaveNewMail:: ; b984
	ds $1

sGeneralSaveTempNumMailInQueue:: ; b985
	ds $1

sGeneralSaveMailboxPage:: ; b986
	ds $1

sGeneralSaveSelectedMailCursorPosition:: ; b987
	ds $1

sGeneralSaveMailOptionSelected:: ; b988
	ds $1

sGeneralSaveBlackBoxCardReceived:: ; b989
	ds BLACK_BOX_OUTPUT_BYTES

sGeneralSaveBillsPCCardReceived:: ; b99d
	ds $2

sGeneralSavePCMenuCursorPosition:: ; b99f
	ds $1

sGeneralSaveGameCenterChips:: ; b9a0
	ds $2

sGeneralSaveGameCenterBankedChips:: ; b9a2
	ds $2

sGeneralSaveClaimedJigglypuffCoin:: ; b9a4
	ds $1

sGeneralSaveOWObj1Flags:: ; b9a5
	ds $1

sGeneralSaveDataEnd::

	ds $e6

; checksum: swapped order
sGeneralSaveDataChecksum1:: ; baa0
	ds $1

sGeneralSaveDataChecksum0:: ; baa1
	ds $1

sGeneralSaveDataChecksumSeed:: ; baa2
	ds $1

; 0: no save
; 1: saved and backed up
; 2: saved but not backed up
sSaveDataState:: ; baa3
	ds $1

; see WRAMToSRAMMapper_ChallengeMachineSave
sChallengeMachineSaveData:: ; baa4

; title text id + dialog name text id for each round in the active set
sChallengeMachineOpponentTitlesAndNames:: ; baa4
	ds (2 + 2) * NUM_CHALLENGE_MACHINE_ROUNDS_PER_SET

sChallengeMachineSetsWonRecords:: ; bab8
sTCGChallengeMachineSetsWonRecord:: ; bab8
	ds $2

sGRChallengeMachineSetsWonRecord:: ; baba
	ds $2

sChallengeMachineCurWinStreaks:: ; babc
sTCGChallengeMachineCurWinStreak:: ; babc
	ds $2

sGRChallengeMachineCurWinStreak:: ; babe
	ds $2

sChallengeMachineWinStreakRecords:: ; bac0
sTCGChallengeMachineWinStreakRecord:: ; bac0
	ds $2

sGRChallengeMachineWinStreakRecord:: ; bac2
	ds $2

sChallengeMachinePlayerNames:: ; bac4
sTCGChallengeMachinePlayerName:: ; bac4
	ds NAME_BUFFER_LENGTH

sGRChallengeMachinePlayerName:: ; bad4
	ds NAME_BUFFER_LENGTH

sChallengeMachineSaveDataEnd::

; checksum: swapped order
sChallengeMachineSaveDataChecksum1:: ; bae4
	ds $1

sChallengeMachineSaveDataChecksum0:: ; bae5
	ds $1

sChallengeMachineSaveDataChecksumSeed:: ; bae6
	ds $1

	ds $19

; saved data of the current duel, including a two-byte checksum
; see SaveDuelDataToDE
sCurrentDuel:: ; bb00
	ds $1
sCurrentDuelChecksum:: ; bb01
	ds $3
sCurrentDuelData:: ; bb04
	ds $352

SECTION "SRAM1", SRAM

; keeps track of last 16 player's names that
; this save file has done Card Pop! with
sCardPopNameList:: ; a000
	ds CARDPOP_NAME_LIST_SIZE

sCardPopRecords:: ; a100
	ds MAX_NUM_CARDPOP_RECORDS * CARDPOP_RECORD_SIZE

SECTION "SRAM2", SRAM

; the same structure as SRAM0
; mainly as a backup, much like tcg1
; see BulkCopySRAM

	ds $1800

sBackupGeneralSaveData:: ; b800

sBackupGeneralSaveDataHeader:: ; b800
	ds $1

sBackupGeneralSaveDataMain:: ; b801

sBackupGeneralSavePlayTimeCounterFrames:: ; b801
	ds $1

sBackupGeneralSavePlayTimeCounterSeconds:: ; b802
	ds $1

sBackupGeneralSavePlayTimeCounterMinutes:: ; b803
	ds $1

sBackupGeneralSavePlayTimeCounterHours:: ; b804
	ds $2

sBackupGeneralSaveCurMusic:: ; b806
	ds $1

sBackupGeneralSaveNextGameEvent:: ; b807
	ds $1

sBackupGeneralSaveNextWarpMap:: ; b808
	ds $1

sBackupGeneralSaveNextWarpPlayerCoords:: ; b809
	ds $2

sBackupGeneralSavePlayerOWObject:: ; b80b
	ds $1

sBackupGeneralSaveCurMapScriptsBank:: ; b80c
	ds $1

sBackupGeneralSaveCurMapScriptsPointer:: ; b80d
	ds $2

sBackupGeneralSaveOverworldMode:: ; b80f
	ds $1

sBackupGeneralSaveOverworldTransition:: ; b810
	ds $1

sBackupGeneralSavePrevMap:: ; b811
	ds $1

sBackupGeneralSaveTempPrevMap:: ; b812
	ds $1

sBackupGeneralSaveCurMap:: ; b813
	ds $1

sBackupGeneralSaveCurOWLocation:: ; b814
	ds $1

sBackupGeneralSaveCurIsland:: ; b815
	ds $1

sBackupGeneralSavePlayerOWLocation:: ; b816
	ds $1

sBackupGeneralSaveNextMapHeaderData:: ; b817
	ds MAPHEADERSTRUCT_LENGTH

sBackupGeneralSaveNextWarpPlayerData:: ; b81c
	ds $3

sBackupGeneralSaveScriptNPC:: ; b81f
	ds $1

sBackupGeneralSaveScriptNPCName:: ; b820
	ds $2

sBackupGeneralSaveSentMailBitfield:: ; b822
	ds $4

sBackupGeneralSaveTempCardDungeonBet:: ; b826
	ds $1

sBackupGeneralSaveEventVars:: ; b827
	ds EVENT_VAR_BYTES - 2

sBackupGeneralSaveGeneralVars:: ; b859
	ds GENERAL_VAR_BYTES - 2

sBackupGeneralSaveOWData:: ; b877
	ds 177

sBackupGeneralSaveNPCStateBuffer:: ; b928
	ds 5 * MAX_NUM_OW_OBJECTS

sBackupGeneralSaveScrollTargetObject:: ; b95a
	ds $1

sBackupGeneralSaveSelectedCoin:: ; b95b
	ds $1

sBackupGeneralSaveCoinPage:: ; b95c
	ds $1

sBackupGeneralSavePauseMenuCursorPosition:: ; b95d
	ds $1

sBackupGeneralSaveMinicomMenuCursorPosition:: ; b95e
	ds $1

sBackupGeneralSaveGiftCenterMenuCursorPosition:: ; b95f
	ds $1

sBackupGeneralSaveNumMailInQueue:: ; b960
	ds $1

sBackupGeneralSaveMailQueue:: ; b961
	ds MAIL_QUEUE_BUFFER_SIZE

sBackupGeneralSaveMailCount:: ; b97a
	ds $1

sBackupGeneralSaveMailList:: ; b97b
	ds MAIL_BUFFER_SIZE

sBackupGeneralSaveNewMail:: ; b984
	ds $1

sBackupGeneralSaveTempNumMailInQueue:: ; b985
	ds $1

sBackupGeneralSaveMailboxPage:: ; b986
	ds $1

sBackupGeneralSaveSelectedMailCursorPosition:: ; b987
	ds $1

sBackupGeneralSaveMailOptionSelected:: ; b988
	ds $1

sBackupGeneralSaveBlackBoxCardReceived:: ; b989
	ds BLACK_BOX_OUTPUT_BYTES

sBackupGeneralSaveBillsPCCardReceived:: ; b99d
	ds $2

sBackupGeneralSavePCMenuCursorPosition:: ; b99f
	ds $1

sBackupGeneralSaveGameCenterChips:: ; b9a0
	ds $2

sBackupGeneralSaveGameCenterBankedChips:: ; b9a2
	ds $2

sBackupGeneralSaveClaimedJigglypuffCoin:: ; b9a4
	ds $1

sBackupGeneralSaveOWObj1Flags:: ; b9a5
	ds $1

sBackupGeneralSaveDataEnd::

	ds $e6

sBackupGeneralSaveDataChecksum1:: ; baa0
	ds $1

sBackupGeneralSaveDataChecksum0:: ; baa1
	ds $1

sBackupGeneralSaveDataChecksumSeed:: ; baa2
	ds $1

; see sSaveDataState
sBackupSaveDataState:: ; baa3
	ds $1

sBackupChallengeMachineSaveData:: ; baa4

sBackupChallengeMachineOpponentTitlesAndNames:: ; baa4
	ds (2 + 2) * NUM_CHALLENGE_MACHINE_ROUNDS_PER_SET

sBackupChallengeMachineSetsWonRecords:: ; bab8
sBackupTCGChallengeMachineSetsWonRecord:: ; bab8
	ds $2

sBackupGRChallengeMachineSetsWonRecord:: ; baba
	ds $2

sBackupChallengeMachineCurWinStreaks:: ; babc
sBackupTCGChallengeMachineCurWinStreak:: ; babc
	ds $2

sBackupGRChallengeMachineCurWinStreak:: ; babe
	ds $2

sBackupChallengeMachineWinStreakRecords:: ; bac0
sBackupTCGChallengeMachineWinStreakRecord:: ; bac0
	ds $2

sBackupGRChallengeMachineWinStreakRecord:: ; bac2
	ds $2

sBackupChallengeMachinePlayerNames:: ; bac4
sBackupTCGChallengeMachinePlayerName:: ; bac4
	ds NAME_BUFFER_LENGTH

sBackupGRChallengeMachinePlayerName:: ; bad4
	ds NAME_BUFFER_LENGTH

sBackupChallengeMachineSaveDataEnd::

sBackupChallengeMachineSaveDataChecksum1:: ; bae4
	ds $1

sBackupChallengeMachineSaveDataChecksum0:: ; bae5
	ds $1

sBackupChallengeMachineSaveDataChecksumSeed:: ; bae6
	ds $1

SECTION "SRAM3", SRAM

; buffers used to temporary store gfx related data
; such as tiles or BG maps
sGfxBuffer0:: ; a000
	ds $400

sGfxBuffer1:: ; a400
	ds $400

sGfxBuffer2:: ; a800
	ds $400

sGfxBuffer3:: ; ac00
	ds $400

sGfxBuffer4:: ; b000
	ds $400

sGfxBuffer5:: ; b400
	ds $400
