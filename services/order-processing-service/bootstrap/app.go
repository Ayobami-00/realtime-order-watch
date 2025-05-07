package bootstrap

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/rs/zerolog/log"
)

type Application struct {
	Env *Env
	Db  db.Store
}

var interruptSignals = []os.Signal{
	os.Interrupt,
	syscall.SIGTERM,
	syscall.SIGINT,
}

func App() Application {
	app := &Application{}
	app.Env = NewEnv()

	ctx, stop := signal.NotifyContext(context.Background(), interruptSignals...)
	defer stop()

	config := app.Env

	connPool, err := pgxpool.New(ctx, config.DBSource)
	if err != nil {
		log.Fatal().Err(err).Msg("cannot connect to db")
	}

	app.Db = db.NewStore(connPool)
	return *app
}
