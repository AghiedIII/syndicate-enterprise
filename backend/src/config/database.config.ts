import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions, TypeOrmOptionsFactory } from '@nestjs/typeorm';

@Injectable()
export class DatabaseConfigService implements TypeOrmOptionsFactory {
  constructor(private configService: ConfigService) {}

  createTypeOrmOptions(): TypeOrmModuleOptions {
    const databaseUrl = this.configService.get<string>('DATABASE_URL');
    const isProduction = this.configService.get('NODE_ENV') === 'production';

    return {
      type: 'postgres',
      url: databaseUrl,
      host: this.configService.get('DATABASE_HOST') || 'localhost',
      port: this.configService.get<number>('DATABASE_PORT') || 5432,
      database: this.configService.get('DATABASE_NAME') || 'syndicate_ledger_db_0',
      username: this.configService.get('DATABASE_USER') || 'postgres',
      password: this.configService.get('DATABASE_PASSWORD') || 'postgres',

      // Entities (we'll use raw SQL for now since schema is pre-built)
      entities: [],
      synchronize: false, // Never auto-sync; use migrations instead
      migrationsRun: false,

      // Connection Pooling
      extra: {
        max: this.configService.get<number>('DATABASE_POOL_MAX') || 10,
        min: this.configService.get<number>('DATABASE_POOL_MIN') || 2,
        connectionTimeoutMillis: 2000,
        idleTimeoutMillis: 30000,
      },

      // Logging
      logging: !isProduction && this.configService.get('ENABLE_QUERY_LOGGING') === 'true',
      logger: 'advanced-console',

      // SSL (for production)
      ssl: isProduction ? { rejectUnauthorized: false } : false,
    };
  }
}
