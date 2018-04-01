// Copyright © 2018 OrcaLLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cmd

import (
    "fmt"
    "strings"
    "strconv"

    "github.com/spf13/cobra"

    "github.com/andrewbackes/chess/fen"
    "github.com/andrewbackes/chess/piece"
    "github.com/andrewbackes/chess/position"
    "github.com/andrewbackes/chess/position/square"
)

var gamedata string

// toFenCmd represents the toFen command
var toFenCmd = &cobra.Command{
    Use:   "toFen",
    Short: "Converts ChessTime gamedata to FEN",
    Long: `Run with something like

$ go run main.go toFen "GOpt:Normal\nBoard:A8=BR,B8=BN,C8=BB,D8=BQ,E8=BK,G8=BN,H8=BR,A7=BP,B7=BP,C7=BP,F7=BP,G7=BP,H7=BP,E6=BP,C5=BB,E4=WP,F3=WN,A2=WP,B2=WP,C2=WP,D2=WP,G2=WP,H2=WP,A1=WR,B1=WN,C1=WB,D1=WQ,E1=WK,F1=WB,H1=WR\nMoveCount:8\nMvSncePwnOrCapture:2\nEP:\nLegMove:E4-E5,F3-D4,F3-H4,F3-G1,F3-G5,F3-E5,A2-A3,A2-A4,B2-B3,B2-B4,C2-C3,C2-C4,D2-D3,D2-D4,G2-G3,G2-G4,H2-H3,H2-H4,B1-C3,B1-A3,D1-E2,E1-E2,F1-E2,F1-D3,F1-C4,F1-B5,F1-A6,H1-G1\nMoves:E2-E4--F--F-F-WP,D7-D5--F--F-F-BP,F2-F3--F--F-F-WP,D5-E4--F-WP-F-F-BP,F3-E4--F-BP-F-F-WP,E7-E6--F--F-F-BP,G1-F3--F--F-F-WN,F8-C5--F--F-F-BB\nCastleSquares:A1,E1,H1,A8,E8,H8"

Will output equivalent FEN positioning.`,
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println(gamedataToFen(gamedata))
    },
}

func init() {
    toFenCmd.Flags().StringVarP(&gamedata, "gamedata", "g", "", "Gamedata to parse")
    toFenCmd.MarkFlagRequired("gamedata")

    rootCmd.AddCommand(toFenCmd)
}

// example of gamedata: "gameData":"GOpt:Normal
// Board:A8=BR,B8=BN,C8=BB,D8=BQ,E8=BK,G8=BN,H8=BR,A7=BP,B7=BP,C7=BP,F7=BP,G7=BP,H7=BP,E6=BP,C5=BB,E4=WP,F3=WN,A2=WP,B2=WP,C2=WP,D2=WP,G2=WP,H2=WP,A1=WR,B1=WN,C1=WB,D1=WQ,E1=WK,F1=WB,H1=WR
// MoveCount:8
// MvSncePwnOrCapture:2
// EP:
// LegMove:E4-E5,F3-D4,F3-H4,F3-G1,F3-G5,F3-E5,A2-A3,A2-A4,B2-B3,B2-B4,C2-C3,C2-C4,D2-D3,D2-D4,G2-G3,G2-G4,H2-H3,H2-H4,B1-C3,B1-A3,D1-E2,E1-E2,F1-E2,F1-D3,F1-C4,F1-B5,F1-A6,H1-G1
// Moves:E2-E4--F--F-F-WP,D7-D5--F--F-F-BP,F2-F3--F--F-F-WP,D5-E4--F-WP-F-F-BP,F3-E4--F-BP-F-F-WP,E7-E6--F--F-F-BP,G1-F3--F--F-F-WN,F8-C5--F--F-F-BB
// CastleSquares:A1,E1,H1,A8,E8,H8"

func gamedataToFen(data string) string {
    /* According to https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation#Definition we have this to accomplish:
       - piece placement from white's perspective - done
       - active colour - done
       - castling availability - TODO
       - En passant target square - TODO
       - halfmove clock - TODO but maybe we don't care
       - fullmove number - done
    */

    piecemap := map[string]piece.Type {
        "P": piece.Pawn,
        "N": piece.Knight,
        "B": piece.Bishop,
        "R": piece.Rook,
        "Q": piece.Queen,
        "K": piece.King,
    }

    colourmap := map[string]piece.Color {
        "W": piece.White,
        "B": piece.Black,
    }

    bored := position.New()
    bored.Clear()

    splitdata := strings.Split(data, "\\n")

    boarddata := strings.Split(splitdata[1], ",")

    // Takes care of item #1 on our list above - piece placement
    for i := 0; i < len(boarddata); i++ {
        pos := strings.Replace(boarddata[i], "Board:", "", -1)

        s := square.Parse(strings.Split(pos, "=")[0])
        p := piece.New(colourmap[string(pos[3])], piecemap[string(pos[4])])

        bored.Put(p, s)
    }

    // Takes care of item #2 on our list above - active colour
    switch string(splitdata[6][strings.LastIndex(splitdata[6], "-") + 1]) {
    case "B":
        bored.ActiveColor = colourmap["W"]
    case "W":
        bored.ActiveColor = colourmap["B"]
    }

    // takes care of the fullmove number
    bored.MoveNumber, _ = strconv.Atoi(strings.Split(splitdata[2], ":")[1])

    fmt.Println(bored)

    encoded, _ := fen.Encode(bored) // TODO: how in the world can i do both of these in one line?
    return encoded
}
