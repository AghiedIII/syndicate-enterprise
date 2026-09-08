import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DatabaseConfigService } from './config/database.config';
import { AuthModule } from './modules/auth/auth.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { EngineersModule } from './modules/engineers/engineers.module';
import { ReconciliationModule } from './modules/reconciliation/reconciliation.module';
import { SettlementModule } from './modules/settlement/settlement.module';

@Module({
  imports: [
    // Global Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Database Connection
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useClass: DatabaseConfigService,
    }),

    // Feature Modules
    AuthModule,
    ProjectsModule,
    EngineersModule,
    ReconciliationModule,
    SettlementModule,
  ],
})
export class AppModule {}
